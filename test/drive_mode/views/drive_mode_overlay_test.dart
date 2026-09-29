import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('DriveModeOverlay', () {
    late WeatherRepository weatherRepository;
    late DriveModeCubit driveModeCubit;
    late AppBloc appBloc;

    /// A mild, clear day, which argues for no mode in particular.
    const mild = Weather(temperature: 14, weatherCode: 0);

    setUp(() {
      weatherRepository = _MockWeatherRepository();
      when(
        () => weatherRepository.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => mild);
    });

    Widget subject() {
      // Built here rather than in `setUp`: a bloc made outside the widget
      // test's zone would process its events on a queue `pump` never
      // reaches.
      appBloc = AppBloc();
      driveModeCubit = DriveModeCubit();
      return RepositoryProvider.value(
        value: weatherRepository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: appBloc),
            BlocProvider.value(value: driveModeCubit),
          ],
          child: MaterialApp(
            theme: AppTheme.rainbow,
            home: const Scaffold(body: DriveModeOverlay()),
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

    testWidgets('lays the active mode out beside the five on offer', (
      tester,
    ) async {
      await pumpOverlay(tester);

      expect(find.text('ACTIVE MODE'), findsOneWidget);
      // Once for the hero, once for its row in the list.
      expect(find.text('Eco'), findsNWidgets(2));
      for (final mode in DriveMode.values) {
        expect(find.text(mode.label), findsWidgets);
      }
      expect(find.byType(SteppedBar), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('picking a mode restates the panel around it', (tester) async {
      await pumpOverlay(tester);

      expect(find.text('MAX'), findsOneWidget); // Eco's regen.

      await tester.tap(find.text(DriveMode.sport.label).last);
      await tester.pumpAndSettle();

      expect(driveModeCubit.state.mode, DriveMode.sport);
      expect(find.text('ACTIVE MODE'), findsOneWidget);
      expect(find.text('SHARP'), findsOneWidget); // Sport's throttle.
      expect(find.text('MAX'), findsNothing);
    });

    testWidgets('the range figure follows the mode', (tester) async {
      await pumpOverlay(tester);

      expect(find.text('ESTIMATED RANGE'), findsOneWidget);
      final eco = driveModeCubit.state.estimatedRange;

      await tester.tap(find.text(DriveMode.sport.label).last);
      await tester.pumpAndSettle();

      expect(driveModeCubit.state.estimatedRange, lessThan(eco));
      expect(
        find.text('${driveModeCubit.state.estimatedRange}'),
        findsOneWidget,
      );
    });

    testWidgets('dragging a bar lands in Custom', (tester) async {
      await pumpOverlay(tester);

      // The throttle bar is the first of the five along the foot.
      await tester.tapAt(tester.getCenter(find.byType(SteppedBar).first));
      await tester.pumpAndSettle();

      expect(driveModeCubit.state.mode, DriveMode.custom);
      expect(find.text('Custom'), findsNWidgets(2));
    });

    testWidgets('marks Snow when the weather argues for it', (tester) async {
      when(
        () => weatherRepository.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer(
        (_) async => const Weather(temperature: -2, weatherCode: 71),
      );

      await pumpOverlay(tester);

      expect(find.text('SNOW FALLING'), findsOneWidget);
    });

    testWidgets('says nothing about the weather on a mild day', (tester) async {
      await pumpOverlay(tester);

      expect(find.text('SNOW FALLING'), findsNothing);
      expect(find.text('ROADS NEAR FREEZING'), findsNothing);
    });

    testWidgets('holds together at the size it grows out of', (tester) async {
      // The panel is laid out at the tapped card's own size while the Hero
      // flight is still running, so the layout has to survive being a
      // fraction of its final width.
      tester.view.physicalSize = const Size(320, 220);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
