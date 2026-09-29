import 'dart:ui' as ui;

import 'package:agl_ivi_vgv_demo/home/views/card_overlay_target.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardOverlayTarget', () {
    /// A card painted the way `rainbow` paints a drive mode: a gradient
    /// with no flat color of its own.
    const gradientCard = BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFFFFA845), Color(0xFFFC77EB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    /// The near-black surface that card's panel settles on.
    const panelSurface = BoxDecoration(color: Color(0xFF17161F));

    const screen = Key('screen');

    Widget subject() {
      return RepaintBoundary(
        key: screen,
        child: MaterialApp(
          // The panel's own chrome is spaced off the theme's extensions,
          // so the test builds under the theme the glitch was reported in
          // rather than Material's bare default.
          theme: AppTheme.rainbow,
          home: Scaffold(
            // Anything the panel fails to cover shows through as this, so
            // it is picked as far from either end of the flight as the two
            // decorations allow.
            backgroundColor: const Color(0xFFFFFFFF),
            body: Center(
              child: SizedBox(
                width: 120,
                height: 80,
                child: CardOverlayTarget(
                  background: gradientCard,
                  overlayBackground: panelSurface,
                  heroTag: 'card',
                  contentBuilder: (_) => const SizedBox.expand(),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
        ),
      );
    }

    /// The color on screen at the middle of the app, which the growing
    /// panel covers for all but the first frames of the flight.
    Future<Color> centerPixel(WidgetTester tester) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(screen),
      );
      late final ui.Image image;
      await tester.runAsync(() async {
        image = await boundary.toImage();
      });
      final data = await tester.runAsync(image.toByteData);
      final x = image.width ~/ 2;
      final y = image.height ~/ 2;
      final offset = (y * image.width + x) * 4;
      final bytes = data!.buffer.asUint8List();
      return Color.fromARGB(
        bytes[offset + 3],
        bytes[offset],
        bytes[offset + 1],
        bytes[offset + 2],
      );
    }

    testWidgets(
      'keeps the panel opaque while it grows out of a gradient card',
      (tester) async {
        await tester.pumpWidget(subject());
        await tester.tap(find.byType(CardOverlayTarget));
        await tester.pump();

        // Sampled across the flight rather than at one point: the
        // decorations only fail to cover in the middle of it, where a
        // surface interpolated between a gradient and a flat color is
        // half transparent and the scaffold behind shows through.
        for (var elapsed = 40; elapsed < 320; elapsed += 40) {
          await tester.pump(const Duration(milliseconds: 40));
          final pixel = await centerPixel(tester);
          expect(
            pixel.computeLuminance(),
            lessThan(0.5),
            reason:
                'the panel washed out towards the white scaffold '
                '${elapsed}ms into the flight',
          );
        }

        await tester.pumpAndSettle();
      },
    );
  });
}
