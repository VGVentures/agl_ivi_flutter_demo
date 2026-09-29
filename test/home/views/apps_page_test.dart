import 'package:agl_ivi_vgv_demo/home/home.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppsPage', () {
    Widget subject() {
      return MaterialApp(
        theme: AppTheme.rainbow,
        home: const Scaffold(body: AppsPage()),
      );
    }

    testWidgets('lists the apps the launcher opens', (tester) async {
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(find.byType(AppLauncherCard), findsNWidgets(3));
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Weather'), findsOneWidget);
      expect(find.text('Music'), findsOneWidget);
    });

    testWidgets('paints each tile in the color of its own app card', (
      tester,
    ) async {
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      final calendar = tester.widget<AppLauncherCard>(
        find.ancestor(
          of: find.text('Calendar'),
          matching: find.byType(AppLauncherCard),
        ),
      );

      expect(
        calendar.background,
        AppTheme.rainbow.extension<AppCardTheme>()!.calendar.background,
      );
    });
  });
}
