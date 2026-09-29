import 'package:open_meteo_api/open_meteo_api.dart' as api;
import 'package:weather_repository/weather_repository.dart';

/// {@template weather_repository}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class WeatherRepository {
  /// {@macro weather_repository}
  const WeatherRepository(this._openMeteoApiClient);

  final api.OpenMeteoApiClient _openMeteoApiClient;

  /// Fetches the current weather at the given coordinates.
  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final weather = await _openMeteoApiClient.getWeather(
      latitude: latitude,
      longitude: longitude,
    );
    return Weather(
      temperature: weather.temperature,
      weatherCode: weather.weatherCode,
    );
  }

  /// Fetches the current weather at the given coordinates along with the
  /// next [days] days.
  Future<Forecast> getForecast({
    required double latitude,
    required double longitude,
    int days = 5,
  }) async {
    final forecast = await _openMeteoApiClient.getForecast(
      latitude: latitude,
      longitude: longitude,
      days: days,
    );
    return Forecast(
      current: Weather(
        temperature: forecast.current.temperature,
        weatherCode: forecast.current.weatherCode,
      ),
      days: [
        for (final day in forecast.days)
          DailyForecast(
            date: day.date,
            condition: WeatherCondition.fromCode(day.weatherCode),
            high: day.temperatureMax,
            low: day.temperatureMin,
            precipitationProbability: day.precipitationProbability,
            windSpeed: day.windSpeed,
            sunrise: day.sunrise,
            sunset: day.sunset,
          ),
      ],
    );
  }
}
