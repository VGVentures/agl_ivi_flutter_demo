import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ivi_vgv_demo/weather/bloc/weather_tile_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  group('WeatherTileBloc', () {
    late WeatherRepository weatherRepository;

    const berlinWeather = Weather(temperature: 14.9, weatherCode: 3);
    const tokyoWeather = Weather(temperature: 22.4, weatherCode: 0);

    WeatherTileBloc buildBloc({AppLocation location = AppLocation.berlin}) =>
        WeatherTileBloc(weatherRepository, location: location);

    void whenWeatherIs(AppLocation location, Weather weather) {
      when(
        () => weatherRepository.getWeather(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      ).thenAnswer((_) async => weather);
    }

    setUp(() {
      weatherRepository = _MockWeatherRepository();
    });

    test('starts on the given city with no reading yet', () {
      expect(
        buildBloc(location: AppLocation.tokyo).state,
        const WeatherTileState(location: AppLocation.tokyo),
      );
    });

    blocTest<WeatherTileBloc, WeatherTileState>(
      'a first reading is the only thing emitted, so nothing stands in for '
      'it while it is on its way',
      setUp: () => whenWeatherIs(AppLocation.berlin, berlinWeather),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const WeatherTileRequested(AppLocation.berlin),
      ),
      expect: () => const [
        WeatherTileState(location: AppLocation.berlin, weather: berlinWeather),
      ],
    );

    blocTest<WeatherTileBloc, WeatherTileState>(
      'refreshing the same city leaves the reading up until the next lands',
      setUp: () => whenWeatherIs(AppLocation.berlin, berlinWeather),
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const WeatherTileRequested(AppLocation.berlin))
        ..add(const WeatherTileRequested(AppLocation.berlin)),
      expect: () => const [
        WeatherTileState(location: AppLocation.berlin, weather: berlinWeather),
      ],
    );

    blocTest<WeatherTileBloc, WeatherTileState>(
      'moving to another city drops the reading rather than labelling it '
      'with the wrong place',
      setUp: () {
        whenWeatherIs(AppLocation.berlin, berlinWeather);
        whenWeatherIs(AppLocation.tokyo, tokyoWeather);
      },
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const WeatherTileRequested(AppLocation.berlin))
        ..add(const WeatherTileRequested(AppLocation.tokyo)),
      expect: () => const [
        WeatherTileState(location: AppLocation.berlin, weather: berlinWeather),
        WeatherTileState(location: AppLocation.tokyo),
        WeatherTileState(location: AppLocation.tokyo, weather: tokyoWeather),
      ],
    );

    blocTest<WeatherTileBloc, WeatherTileState>(
      'a failed request says nothing, leaving the card as it was',
      setUp: () {
        whenWeatherIs(AppLocation.berlin, berlinWeather);
        when(
          () => weatherRepository.getWeather(
            latitude: AppLocation.tokyo.latitude,
            longitude: AppLocation.tokyo.longitude,
          ),
        ).thenThrow(Exception('offline'));
      },
      build: buildBloc,
      act: (bloc) => bloc
        ..add(const WeatherTileRequested(AppLocation.berlin))
        ..add(const WeatherTileRequested(AppLocation.tokyo)),
      expect: () => const [
        WeatherTileState(location: AppLocation.berlin, weather: berlinWeather),
        // The city still changes — only the reading is missing.
        WeatherTileState(location: AppLocation.tokyo),
      ],
    );

    blocTest<WeatherTileBloc, WeatherTileState>(
      'a failed refresh of the same city emits nothing at all',
      setUp: () {
        when(
          () => weatherRepository.getWeather(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenThrow(Exception('offline'));
      },
      build: buildBloc,
      act: (bloc) => bloc.add(
        const WeatherTileRequested(AppLocation.berlin),
      ),
      expect: () => const <WeatherTileState>[],
    );
  });
}
