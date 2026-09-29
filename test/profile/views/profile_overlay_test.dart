import 'package:agl_ivi_vgv_demo/profile/profile.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileOverlay', () {
    late ActiveProfileCubit activeProfileCubit;

    Widget subject() {
      // Built here rather than in `setUp`: a cubit made outside the widget
      // test's zone would process its work on a queue `pump` never reaches.
      activeProfileCubit = ActiveProfileCubit();
      return BlocProvider.value(
        value: activeProfileCubit,
        child: MaterialApp(
          theme: AppTheme.rainbow,
          home: const Scaffold(body: ProfileOverlay()),
        ),
      );
    }

    /// Lays the panel out on a head unit sized window and settles it.
    Future<void> pumpOverlay(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();
    }

    testWidgets('lays the active driver out beside the ones on offer', (
      tester,
    ) async {
      await pumpOverlay(tester);

      expect(find.text('ACTIVE DRIVER'), findsOneWidget);
      // Once beside the active driver's avatar, once in their row.
      expect(find.text(DriverProfile.jorge.name), findsNWidgets(2));
      for (final profile in DriverProfile.values) {
        expect(find.text(profile.name), findsWidgets);
      }
    });

    testWidgets('names every setting the active driver carries', (
      tester,
    ) async {
      await pumpOverlay(tester);

      const profile = DriverProfile.jorge;
      expect(find.text('THEME'), findsOneWidget);
      expect(find.text(profile.themeId.label), findsOneWidget);
      expect(find.text(profile.location.label), findsOneWidget);
      expect(find.text(profile.unitSystem.label), findsOneWidget);
      expect(find.text(profile.timeFormat.label), findsOneWidget);
      expect(find.text(profile.driveMode.label), findsOneWidget);
      expect(find.text(profile.phone.name), findsOneWidget);
    });

    testWidgets('picking a driver restates the strip in their settings', (
      tester,
    ) async {
      await pumpOverlay(tester);

      await tester.tap(find.text(DriverProfile.sam.name));
      await tester.pumpAndSettle();

      expect(activeProfileCubit.state, DriverProfile.sam);
      // The panel is now titled with the driver that was picked, so the
      // strip and the list beside it cannot disagree.
      expect(find.text(DriverProfile.sam.name), findsNWidgets(2));
      expect(find.text(DriverProfile.sam.driveMode.label), findsOneWidget);
      expect(find.text(DriverProfile.sam.phone.name), findsOneWidget);
    });

    testWidgets('marks the active driver and only that one', (tester) async {
      await pumpOverlay(tester);

      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.tap(find.text(DriverProfile.lars.name));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('Profile card', () {
    testWidgets("is drawn in the active driver's name", (tester) async {
      final cubit = ActiveProfileCubit();
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: AppTheme.rainbow,
            home: const Scaffold(
              body: Center(
                child: SizedBox(width: 400, height: 90, child: Profile()),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(DriverProfile.jorge.name.toUpperCase()),
        findsOneWidget,
      );

      cubit.select(DriverProfile.mei);
      await tester.pumpAndSettle();

      expect(find.text(DriverProfile.mei.name.toUpperCase()), findsOneWidget);
    });
  });
}
