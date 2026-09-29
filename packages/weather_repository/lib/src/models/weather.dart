import 'package:equatable/equatable.dart';

/// What the sky is doing, coarse enough that one icon and one label can
/// stand for it.
///
/// Open Meteo reports a WMO code with far more resolution than a dashboard
/// needs — four kinds of freezing drizzle, three intensities of rain — so
/// [fromCode] folds the scale down to the distinctions a driver glancing at
/// the panel can actually use.
enum WeatherCondition {
  clear,
  partlyCloudy,
  cloudy,
  foggy,
  drizzle,
  rainy,
  snowy,
  stormy,
  unknown;

  /// The condition [code] stands for, on the WMO scale Open Meteo reports.
  static WeatherCondition fromCode(double code) {
    return switch (code) {
      0 => WeatherCondition.clear,
      1 || 2 => WeatherCondition.partlyCloudy,
      3 => WeatherCondition.cloudy,
      45 || 48 => WeatherCondition.foggy,
      51 || 53 || 55 || 56 || 57 => WeatherCondition.drizzle,
      61 || 63 || 65 || 66 || 67 || 80 || 81 || 82 => WeatherCondition.rainy,
      71 || 73 || 75 || 77 || 85 || 86 => WeatherCondition.snowy,
      95 || 96 || 99 => WeatherCondition.stormy,
      _ => WeatherCondition.unknown,
    };
  }
}

class Weather extends Equatable {
  const Weather({
    required this.temperature,
    required this._weatherCode,
  });

  final double temperature;
  final double _weatherCode;

  @override
  List<Object?> get props => [temperature, _weatherCode];

  WeatherCondition get weatherCondition =>
      WeatherCondition.fromCode(_weatherCode);
}
