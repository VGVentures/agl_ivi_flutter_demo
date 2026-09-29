import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/weather/weather.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

DailyForecast _day(int day, {double high = 20, double low = 10}) {
  return DailyForecast(
    date: DateTime(2026, 9, day),
    condition: WeatherCondition.values[day % WeatherCondition.values.length],
    high: high,
    low: low,
    precipitationProbability: day * 10,
    windSpeed: 12,
    sunrise: DateTime(2026, 9, day, 6, 30),
    sunset: DateTime(2026, 9, day, 19, 15),
  );
}

void main() {
  group('WeatherOverlay', () {
    late WeatherRepository weatherRepository;

    final forecast = Forecast(
      current: const Weather(temperature: 14.9, weatherCode: 3),
      days: [
        _day(24, high: 21, low: 11),
        _day(25, high: 26, low: 14),
        _day(26, high: 17, low: 6),
        _day(27, high: 19, low: 9),
        _day(28, high: 23, low: 12),
      ],
    );

    late AppBloc appBloc;

    setUp(() {
      weatherRepository = _MockWeatherRepository();
      when(
        () => weatherRepository.getForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => forecast);
    });

    Widget subject() {
      // Built here rather than in `setUp`: a bloc made outside the widget
      // test's zone would process its events on a queue `pump` never
      // reaches.
      appBloc = AppBloc();
      return RepositoryProvider.value(
        value: weatherRepository,
        child: BlocProvider.value(
          value: appBloc,
          child: MaterialApp(
            theme: AppTheme.rainbow,
            home: const Scaffold(body: WeatherOverlay()),
          ),
        ),
      );
    }

    testWidgets('lays the forecast out on a head unit sized window', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(find.text('BERLIN'), findsOneWidget);
      expect(find.text('15°'), findsOneWidget);
      expect(find.text('5-DAY FORECAST'), findsOneWidget);
      expect(find.text('TODAY'), findsOneWidget);
      expect(find.byType(WeatherForecastRow), findsNWidgets(5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('holds together at the size it grows out of', (tester) async {
      // The panel is laid out at the tapped card's own size while the Hero
      // flight is still running, so the layout has to survive being a
      // fraction of its final width.
      tester.view.physicalSize = const Size(260, 200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('reports in Celsius and km/h until another system is picked', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(find.text('15°'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.text('H 21°   L 11°'), findsOneWidget);
      expect(find.text('12 km/h'), findsOneWidget);
    });

    testWidgets('picking imperial restates the whole panel in Fahrenheit', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      appBloc.add(UnitSystemSelected(AppUnitSystem.imperial));
      await tester.pumpAndSettle();

      // 14.9 °C reads as 59 °F, and today's 21/11 as 70/52.
      expect(find.text('59°'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('H 70°   L 52°'), findsOneWidget);
      expect(find.text('7 mph'), findsOneWidget);
      // No Celsius reading is left standing beside the Fahrenheit ones.
      expect(find.text('15°'), findsNothing);
      expect(find.text('C'), findsNothing);
      expect(find.text('12 km/h'), findsNothing);
    });

    testWidgets('the forecast rows are converted along with the scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      appBloc.add(UnitSystemSelected(AppUnitSystem.imperial));
      await tester.pumpAndSettle();

      final rows = tester
          .widgetList<WeatherForecastRow>(find.byType(WeatherForecastRow))
          .toList();
      // The warmest day of the week, 26/14 °C, reads as 79/57 °F.
      expect(rows[1].high, 79);
      expect(rows[1].low, 57);
      // Every row is measured against the same converted scale, so the
      // bars keep the shape they had in Celsius.
      expect(rows.every((row) => row.scaleLow == rows.first.scaleLow), isTrue);
      expect(rows.first.scaleLow, closeTo(42.8, 0.001));
      expect(rows.first.scaleHigh, closeTo(78.8, 0.001));
    });

    testWidgets('picking imperial does not re-fetch the forecast', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      appBloc.add(UnitSystemSelected(AppUnitSystem.imperial));
      await tester.pumpAndSettle();

      verify(
        () => weatherRepository.getForecast(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).called(1);
    });
  });
}
