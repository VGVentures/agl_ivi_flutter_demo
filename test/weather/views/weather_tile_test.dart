import 'dart:async';
import 'dart:io';

import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ivi_vgv_demo/weather/weather.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('WeatherTile', () {
    late WeatherRepository weatherRepository;
    late AppBloc appBloc;

    const berlinWeather = Weather(temperature: 14.9, weatherCode: 3);
    const tokyoWeather = Weather(temperature: 22.4, weatherCode: 0);

    setUp(() {
      weatherRepository = _MockWeatherRepository();
    });

    /// Stubs the reading [location] answers with.
    ///
    /// The future is made by the caller, inside the test body: one built in
    /// `setUp` belongs to the zone outside the widget test, and nothing
    /// awaiting it would ever be resumed by `pump`.
    void whenReading(AppLocation location, Future<Weather> reading) {
      when(
        () => weatherRepository.getWeather(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      ).thenAnswer((_) => reading);
    }

    Widget subject() {
      // Built here rather than in `setUp` for the same reason the readings
      // are: a bloc made outside the widget test's zone would process its
      // events on a queue that `pump` never reaches.
      appBloc = AppBloc();
      return RepositoryProvider.value(
        value: weatherRepository,
        child: BlocProvider.value(
          value: appBloc,
          child: MaterialApp(
            theme: AppTheme.rainbow,
            home: const Scaffold(
              body: SizedBox(width: 260, height: 200, child: WeatherTile()),
            ),
          ),
        ),
      );
    }

    testWidgets('names its city and waits without a spinner', (tester) async {
      whenReading(AppLocation.berlin, Completer<Weather>().future);

      await tester.pumpWidget(subject());
      await tester.pump();

      expect(find.text('BERLIN'), findsOneWidget);
      // The card sets the reading, the degree mark and the scale as
      // three runs so the last two can share a column, so each is
      // asserted on its own.
      expect(find.text('—'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('a reading landing changes the temperature and nothing else', (
      tester,
    ) async {
      final reading = Completer<Weather>();
      whenReading(AppLocation.berlin, reading.future);

      await tester.pumpWidget(subject());
      await tester.pump();
      expect(find.text('—'), findsOneWidget);

      reading.complete(berlinWeather);
      await tester.pumpAndSettle();

      expect(find.text('15'), findsOneWidget);
      expect(find.text('—'), findsNothing);
      expect(find.text('BERLIN'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('a failed request leaves the card standing', (tester) async {
      when(
        () => weatherRepository.getWeather(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenThrow(Exception('offline'));

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(find.text('BERLIN'), findsOneWidget);
      expect(find.text('—'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('washes the card with the condition it is reporting', (
      tester,
    ) async {
      // Code 3 is overcast, which the card draws as its dotted cloud
      // rather than the dotted sun it used to draw whatever the sky was.
      whenReading(AppLocation.berlin, Future.value(berlinWeather));

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(
        _watermarkOf(tester),
        WeatherTreatment.cloudy.watermarkAsset,
      );
    });

    testWidgets('claims nothing about the sky before a reading', (
      tester,
    ) async {
      whenReading(AppLocation.berlin, Completer<Weather>().future);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(find.byType(SvgPicture), findsNothing);
    });

    testWidgets('reports in Celsius until another system is picked', (
      tester,
    ) async {
      whenReading(AppLocation.berlin, Future.value(berlinWeather));

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(find.text('15'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('picking imperial restates the card in Fahrenheit', (
      tester,
    ) async {
      whenReading(AppLocation.berlin, Future.value(berlinWeather));

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      appBloc.add(UnitSystemSelected(AppUnitSystem.imperial));
      await tester.pumpAndSettle();

      // 14.9 °C reads as 59 °F, off the reading already in hand: the card
      // is not sent back to the network for it.
      expect(find.text('59'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('15'), findsNothing);
      expect(find.text('C'), findsNothing);
      verify(
        () => weatherRepository.getWeather(
          latitude: AppLocation.berlin.latitude,
          longitude: AppLocation.berlin.longitude,
        ),
      ).called(1);
    });

    testWidgets('waits in whichever units are picked, without a reading', (
      tester,
    ) async {
      whenReading(AppLocation.berlin, Completer<Weather>().future);

      await tester.pumpWidget(subject());
      await tester.pump();

      appBloc.add(UnitSystemSelected(AppUnitSystem.imperial));
      await tester.pumpAndSettle();

      expect(find.text('—'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('picking another city renames the card and re-reads it', (
      tester,
    ) async {
      whenReading(AppLocation.berlin, Future.value(berlinWeather));
      whenReading(AppLocation.tokyo, Future.value(tokyoWeather));

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();
      expect(find.text('15'), findsOneWidget);

      appBloc.add(LocationSelected(AppLocation.tokyo));
      await tester.pumpAndSettle();

      expect(find.text('TOKYO'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      // Berlin's reading never appears under Tokyo's name.
      expect(find.text('15'), findsNothing);
      // Tokyo is clear, so the wash follows the reading across.
      expect(_watermarkOf(tester), WeatherTreatment.sunny.watermarkAsset);
    });
  });

  group('WeatherTreatment', () {
    test('every condition has a watermark that is actually bundled', () {
      for (final treatment in WeatherTreatment.values) {
        // The tests run from the repository root, where a package asset
        // path is also its path on disk.
        expect(
          File(treatment.watermarkAsset).existsSync(),
          isTrue,
          reason:
              '${treatment.name} names a watermark that is not bundled: '
              '${treatment.watermarkAsset}',
        );
      }
    });

    test('no two conditions are washed in with the same shape', () {
      final watermarks = WeatherTreatment.values
          .map((treatment) => treatment.watermarkAsset)
          .toSet();
      expect(watermarks, hasLength(WeatherTreatment.values.length));
    });
  });
}

/// The asset behind the card right now, or `null` when it draws none.
String? _watermarkOf(WidgetTester tester) {
  final pictures = tester.widgetList<SvgPicture>(find.byType(SvgPicture));
  if (pictures.isEmpty) return null;
  return (pictures.single.bytesLoader as SvgAssetLoader).assetName;
}
