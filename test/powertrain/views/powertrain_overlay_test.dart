import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ivi_vgv_demo/powertrain/powertrain.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PowertrainOverlay', () {
    late DriveModeCubit driveModeCubit;

    /// Round figures, so what the panel writes can be checked against the
    /// arithmetic rather than against the demo's own numbers.
    const telemetry = PowertrainTelemetry(
      batteryPercent: 50,
      packKwh: 100,
      trips: [
        // 20 kWh for 20 miles: 1 mi/kWh, under the average.
        Trip(label: 'A', batteryPercent: 20, miles: 20),
        // 30 kWh for 150 miles: 5 mi/kWh, over it.
        Trip(label: 'B', batteryPercent: 30, miles: 150),
      ],
      boostPsi: 8,
      boostPeakPsi: 12,
    );

    Widget subject() {
      // Built here rather than in `setUp`: a cubit made outside the widget
      // test's zone would process its events on a queue `pump` never
      // reaches.
      driveModeCubit = DriveModeCubit();
      return BlocProvider.value(
        value: driveModeCubit,
        child: MaterialApp(
          theme: AppTheme.rainbow,
          home: const Scaffold(
            body: PowertrainOverlay(telemetry: telemetry),
          ),
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

    testWidgets('lays the three cards out as one panel', (tester) async {
      await pumpOverlay(tester);

      expect(find.text('EV RANGE'), findsOneWidget);
      expect(find.text('EFFICIENCY'), findsOneWidget);
      expect(find.text('BOOST'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('quotes the charge and what is left in the pack', (
      tester,
    ) async {
      await pumpOverlay(tester);

      expect(find.text('50%'), findsOneWidget);
      expect(find.text('50.0 kWh'), findsOneWidget);
    });

    testWidgets('the range is the one the drive mode panel moves', (
      tester,
    ) async {
      await pumpOverlay(tester);

      // Eco, which the car boots in, buys range off the baseline.
      expect(
        find.text('${driveModeCubit.state.estimatedRange}'),
        findsOneWidget,
      );
      expect(find.text('IN ECO'), findsOneWidget);

      driveModeCubit.select(DriveMode.sport);
      await tester.pumpAndSettle();

      expect(
        find.text('${driveModeCubit.state.estimatedRange}'),
        findsOneWidget,
      );
      expect(find.text('IN SPORT'), findsOneWidget);
    });

    testWidgets('the baseline mode is named as such rather than as +0%', (
      tester,
    ) async {
      await pumpOverlay(tester);

      driveModeCubit.select(DriveMode.comfort);
      await tester.pumpAndSettle();

      expect(find.text('BASELINE'), findsOneWidget);
    });

    testWidgets('plots every trip with the rate it achieved', (tester) async {
      await pumpOverlay(tester);

      for (final trip in telemetry.trips) {
        expect(find.text(trip.label), findsOneWidget);
        expect(find.text('${trip.batteryPercent}%'), findsOneWidget);
        expect(find.text('${trip.miles} mi'), findsOneWidget);
      }
      expect(find.text('1.0'), findsOneWidget);
      expect(find.text('5.0'), findsOneWidget);
    });

    testWidgets('sums the history up under the chart', (tester) async {
      await pumpOverlay(tester);

      expect(find.text('3.4 mi/kWh average'), findsOneWidget);
      expect(find.text('5.0 mi/kWh'), findsOneWidget); // Best.
      expect(find.text('170 mi'), findsOneWidget);
      expect(find.text('50 kWh'), findsOneWidget);
    });

    testWidgets('writes the boost reading against its own band', (
      tester,
    ) async {
      await pumpOverlay(tester);

      expect(find.text('8.00'), findsOneWidget);
      expect(find.text('psi'), findsOneWidget);
      expect(find.text('12.0 psi'), findsOneWidget); // Peak.
      expect(find.text('14.5 psi'), findsOneWidget); // Wastegate.
      expect(find.text('-10 VAC'), findsOneWidget);
      expect(find.text('+14.5'), findsOneWidget);
    });

    testWidgets('holds together at the size it grows out of', (tester) async {
      // The panel is laid out at the tapped card's own size while the Hero
      // flight is still running, so the layout has to survive being a
      // fraction of its final width.
      tester.view.physicalSize = const Size(300, 240);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('names which end of the band the reading is at', (
      tester,
    ) async {
      await pumpOverlay(tester);

      expect(find.text('ON BOOST'), findsOneWidget);
    });

    testWidgets('off the throttle the gauge says so rather than "on boost"', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      driveModeCubit = DriveModeCubit();
      await tester.pumpWidget(
        BlocProvider.value(
          value: driveModeCubit,
          child: MaterialApp(
            theme: AppTheme.rainbow,
            home: Scaffold(
              body: PowertrainOverlay(
                telemetry: PowertrainTelemetry(
                  batteryPercent: telemetry.batteryPercent,
                  packKwh: telemetry.packKwh,
                  trips: telemetry.trips,
                  boostPsi: -6.2,
                  boostPeakPsi: telemetry.boostPeakPsi,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('VACUUM'), findsOneWidget);
      expect(find.text('-6.20'), findsOneWidget);
    });
  });
}
