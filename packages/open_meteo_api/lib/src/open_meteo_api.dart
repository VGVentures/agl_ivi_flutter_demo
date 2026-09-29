import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_meteo_api/open_meteo_api.dart';

/// Exception thrown when locationSearch fails.
class LocationRequestFailure implements Exception {}

/// Exception thrown when the provided location is not found.
class LocationNotFoundFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// Exception thrown when weather for provided location is not found.
class WeatherNotFoundFailure implements Exception {}

/// {@template open_meteo_api_client}
/// Dart API Client which wraps the [Open Meteo API](https://open-meteo.com).
/// {@endtemplate}
class OpenMeteoApiClient {
  /// {@macro open_meteo_api_client}
  OpenMeteoApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static const _baseUrlWeather = 'api.open-meteo.com';
  static const _baseUrlGeocoding = 'geocoding-api.open-meteo.com';

  final http.Client _httpClient;

  /// Finds a [Location] `/v1/search/?name=(query)`.
  Future<Location> locationSearch(String query) async {
    final locationRequest = Uri.https(
      _baseUrlGeocoding,
      '/v1/search',
      {'name': query, 'count': '1'},
    );
    final locationResponse = await _httpClient.get(locationRequest);
    if (locationResponse.statusCode != 200) {
      throw LocationRequestFailure();
    }
    final locationJson = jsonDecode(locationResponse.body) as Map;
    if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();
    final results = locationJson['results'] as List;
    if (results.isEmpty) throw LocationNotFoundFailure();
    return Location.fromJson(results.first as Map<String, dynamic>);
  }

  /// Fetches [Weather] for a given [latitude] and [longitude].
  Future<Weather> getWeather({
    required double latitude,
    required double longitude,
  }) async {
    final weatherRequest = Uri.https(_baseUrlWeather, 'v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current_weather': 'true',
    });

    final weatherResponse = await _httpClient.get(weatherRequest);

    if (weatherResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final bodyJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;

    if (!bodyJson.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }

    final weatherJson = bodyJson['current_weather'] as Map<String, dynamic>;

    return Weather.fromJson(weatherJson);
  }

  /// Fetches the current weather plus the next [days] days at a given
  /// [latitude] and [longitude].
  ///
  /// Asked for in one request rather than two, so the current reading and
  /// the day it belongs to are always from the same moment.
  Future<Forecast> getForecast({
    required double latitude,
    required double longitude,
    int days = 5,
  }) async {
    final forecastRequest = Uri.https(_baseUrlWeather, 'v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current_weather': 'true',
      'daily': 'weathercode,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,windspeed_10m_max,sunrise,sunset',
      // The days are the city's own: 'auto' resolves the zone from the
      // coordinates, so "today" is today where the weather is rather than
      // where the head unit is, and sunrise and sunset come back on that
      // city's wall clock.
      'timezone': 'auto',
      'forecast_days': '$days',
    });

    final forecastResponse = await _httpClient.get(forecastRequest);

    if (forecastResponse.statusCode != 200) {
      throw WeatherRequestFailure();
    }

    final bodyJson =
        jsonDecode(forecastResponse.body) as Map<String, dynamic>;

    if (!bodyJson.containsKey('current_weather') ||
        !bodyJson.containsKey('daily')) {
      throw WeatherNotFoundFailure();
    }

    return Forecast(
      current: Weather.fromJson(
        bodyJson['current_weather'] as Map<String, dynamic>,
      ),
      days: DailyWeather.listFromJson(
        bodyJson['daily'] as Map<String, dynamic>,
      ),
    );
  }

  /// Closes the underlying http client.
  void close() {
    _httpClient.close();
  }
}
