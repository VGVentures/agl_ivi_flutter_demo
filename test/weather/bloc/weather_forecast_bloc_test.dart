import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ivi_vgv_demo/weather/bloc/weather_forecast_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_repository/weather_repository.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

DailyForecast _day(int day, {double high = 20, double low = 10}) {
  return DailyForecast(
    date: DateTime(2026, 9, day),
    condition: WeatherCondition.clear,
    high: high,
    low: low,
    precipitationProbability: 0,
    windSpeed: 12,
    sunrise: DateTime(2026, 9, day, 6, 30),
    sunset: DateTime(2026, 9, day, 19, 15),
  );
}

void main() {
  group('WeatherForecastBloc', () {
    late WeatherRepository weatherRepository;

    final forecast = Forecast(
      current: const Weather(temperature: 18, weatherCode: 0),
      days: [for (var day = 1; day <= 5; day++) _day(day)],
    );

    setUp(() {
      weatherRepository = _MockWeatherRepository();
    });

    test('initial state is loading', () {
      expect(
        WeatherForecastBloc(weatherRepository).state,
        const WeatherForecastLoading(),
      );
    });

    blocTest<WeatherForecastBloc, WeatherForecastState>(
      'WeatherForecastRequested loads the forecast for the given city',
      setUp: () {
        when(
          () => weatherRepository.getForecast(
            latitude: AppLocation.tokyo.latitude,
            longitude: AppLocation.tokyo.longitude,
          ),
        ).thenAnswer((_) async => forecast);
      },
      build: () => WeatherForecastBloc(weatherRepository),
      act: (bloc) => bloc.add(
        const WeatherForecastRequested(AppLocation.tokyo),
      ),
      expect: () => [
        const WeatherForecastLoading(),
        WeatherForecastLoadSuccess(
          location: AppLocation.tokyo,
          forecast: forecast,
        ),
      ],
    );

    blocTest<WeatherForecastBloc, WeatherForecastState>(
      'a failed request leaves the panel with nothing to draw',
      setUp: () {
        when(
          () => weatherRepository.getForecast(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenThrow(Exception('offline'));
      },
      build: () => WeatherForecastBloc(weatherRepository),
      act: (bloc) => bloc.add(
        const WeatherForecastRequested(AppLocation.berlin),
      ),
      expect: () => const [
        WeatherForecastLoading(),
        WeatherForecastLoadFailed(),
      ],
    );

    blocTest<WeatherForecastBloc, WeatherForecastState>(
      'a forecast with no days is reported the way a failure is',
      setUp: () {
        when(
          () => weatherRepository.getForecast(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer(
          (_) async => const Forecast(
            current: Weather(temperature: 18, weatherCode: 0),
            days: [],
          ),
        );
      },
      build: () => WeatherForecastBloc(weatherRepository),
      act: (bloc) => bloc.add(
        const WeatherForecastRequested(AppLocation.berlin),
      ),
      expect: () => const [
        WeatherForecastLoading(),
        WeatherForecastLoadFailed(),
      ],
    );

    blocTest<WeatherForecastBloc, WeatherForecastState>(
      'a second request refetches, so a change of city reloads the panel',
      setUp: () {
        when(
          () => weatherRepository.getForecast(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
          ),
        ).thenAnswer((_) async => forecast);
      },
      build: () => WeatherForecastBloc(weatherRepository),
      act: (bloc) => bloc
        ..add(const WeatherForecastRequested(AppLocation.berlin))
        ..add(const WeatherForecastRequested(AppLocation.tokyo)),
      expect: () => [
        const WeatherForecastLoading(),
        WeatherForecastLoadSuccess(
          location: AppLocation.berlin,
          forecast: forecast,
        ),
        const WeatherForecastLoading(),
        WeatherForecastLoadSuccess(
          location: AppLocation.tokyo,
          forecast: forecast,
        ),
      ],
      verify: (_) {
        verify(
          () => weatherRepository.getForecast(
            latitude: AppLocation.tokyo.latitude,
            longitude: AppLocation.tokyo.longitude,
          ),
        ).called(1);
      },
    );
  });

  group('Forecast', () {
    test('the scale spans the coldest low and the warmest high', () {
      final forecast = Forecast(
        current: const Weather(temperature: 18, weatherCode: 0),
        days: [
          _day(1, high: 21, low: 11),
          _day(2, high: 26, low: 14),
          _day(3, high: 17, low: 6),
        ],
      );

      expect(forecast.low, 6);
      expect(forecast.high, 26);
      expect(forecast.today, forecast.days.first);
    });
  });
}
