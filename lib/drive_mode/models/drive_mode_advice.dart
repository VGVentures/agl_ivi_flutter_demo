import 'package:agl_ui/agl_ui.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

/// {@template drive_mode_advice}
/// A mode the conditions outside argue for, and the reason they do.
///
/// The Weather card already knows what the road is likely to be like, and
/// the Drive Mode panel is where that knowledge is worth something: rather
/// than leave the driver to join the two up, the panel marks the mode the
/// forecast points at and says why in three words.
///
/// Only ever points at [DriveMode.snow]. Nothing in a forecast argues for
/// Sport, and a panel that recommended something on a clear day would be
/// noise the driver learns to ignore.
/// {@endtemplate}
class DriveModeAdvice extends Equatable {
  /// {@macro drive_mode_advice}
  const DriveModeAdvice({required this.mode, required this.reason});

  /// The temperature at or below which standing water on a road is likely
  /// to be ice, in Celsius. Above zero, because a road surface loses heat
  /// faster than the air above it.
  static const _icyRoadCelsius = 2.0;

  /// How cold falling rain has to be before it is worth treating as
  /// freezing rain, in Celsius.
  static const _freezingRainCelsius = 4.0;

  /// The mode being suggested.
  final DriveMode mode;

  /// Why, short enough to sit on a badge beside the mode's name.
  final String reason;

  /// What [weather] argues for, or `null` when it argues for nothing —
  /// which is most days, and is the answer while no reading has arrived.
  static DriveModeAdvice? forWeather(Weather? weather) {
    if (weather == null) return null;

    final condition = weather.weatherCondition;
    if (condition == WeatherCondition.snowy) {
      return const DriveModeAdvice(
        mode: DriveMode.snow,
        reason: 'SNOW FALLING',
      );
    }
    if (weather.temperature <= _icyRoadCelsius) {
      return const DriveModeAdvice(
        mode: DriveMode.snow,
        reason: 'ROADS NEAR FREEZING',
      );
    }
    if (weather.temperature <= _freezingRainCelsius &&
        (condition == WeatherCondition.rainy ||
            condition == WeatherCondition.drizzle)) {
      return const DriveModeAdvice(
        mode: DriveMode.snow,
        reason: 'FREEZING RAIN LIKELY',
      );
    }
    return null;
  }

  @override
  List<Object?> get props => [mode, reason];
}
