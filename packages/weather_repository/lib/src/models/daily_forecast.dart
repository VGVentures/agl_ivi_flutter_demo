import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

/// One day of the forecast, summarized the way a dashboard shows it: a
/// single condition, the range the temperature will move through, and the
/// few numbers worth a glance.
class DailyForecast extends Equatable {
  const DailyForecast({
    required this.date,
    required this.condition,
    required this.high,
    required this.low,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
  });

  /// The day this covers, on the city's own calendar.
  final DateTime date;

  final WeatherCondition condition;

  /// The day's high, in degrees Celsius.
  final double high;

  /// The day's low, in degrees Celsius.
  final double low;

  /// The highest chance of precipitation across the day, as a percentage.
  final int precipitationProbability;

  /// The day's strongest wind, in km/h.
  final double windSpeed;

  /// Sunrise, on the city's wall clock.
  final DateTime sunrise;

  /// Sunset, on the city's wall clock.
  final DateTime sunset;

  @override
  List<Object?> get props => [
    date,
    condition,
    high,
    low,
    precipitationProbability,
    windSpeed,
    sunrise,
    sunset,
  ];
}
