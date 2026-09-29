import 'package:equatable/equatable.dart';

/// Which of the two seats a set of climate controls belongs to.
///
/// The head unit carries one set per side, and the two are set
/// independently: a driver turning their own seat heater up is not a
/// request to cook the passenger.
enum CabinSide { driver, passenger }

/// {@template cabin_climate}
/// What one side of the cabin is set to.
///
/// Everything the permanent controls along the foot of the screen can
/// move, in one value: a profile can then hand the cabin a whole preset
/// rather than reaching for five separate controls in turn.
/// {@endtemplate}
class CabinClimate extends Equatable {
  /// {@macro cabin_climate}
  const CabinClimate({
    this.temperature = 68,
    this.fanSpeed = 0,
    this.seatRecline = 0,
    this.seatHeat = 0,
    this.isAcOn = false,
  });

  /// The coldest temperature that can be set.
  static const minTemperature = 55.0;

  /// The hottest temperature that can be set.
  static const maxTemperature = 90.0;

  /// The highest fan, recline and seat heat setting, and the number of
  /// lights on each of their indicators.
  ///
  /// One number for all three: they are drawn as the same row of lights, so
  /// three different ceilings would make the same indicator mean three
  /// things.
  static const maxLevel = 3;

  /// The target temperature, on the scale the controls are marked in.
  final double temperature;

  /// How hard the cabin fan is blowing, 0 (off) to [maxLevel].
  final int fanSpeed;

  /// How far the seat is reclined, 0 (upright) to [maxLevel].
  final int seatRecline;

  /// How hot the seat heater is set, 0 (off) to [maxLevel].
  final int seatHeat;

  /// Whether the air conditioning is running.
  final bool isAcOn;

  /// A copy with the temperature moved to [value], clamped to the range the
  /// controls actually offer.
  CabinClimate withTemperature(double value) =>
      copyWith(temperature: value.clamp(minTemperature, maxTemperature));

  /// A copy one fan speed further on, wrapping back to off after
  /// [maxLevel].
  CabinClimate withNextFanSpeed() => copyWith(fanSpeed: _next(fanSpeed));

  /// A copy one recline position further on, wrapping back to upright after
  /// [maxLevel].
  CabinClimate withNextSeatRecline() =>
      copyWith(seatRecline: _next(seatRecline));

  /// A copy one heat level further on, wrapping back to off after
  /// [maxLevel].
  CabinClimate withNextSeatHeat() => copyWith(seatHeat: _next(seatHeat));

  /// A copy with the air conditioning switched the other way.
  CabinClimate withAcToggled() => copyWith(isAcOn: !isAcOn);

  /// The level after [level], wrapping back to off past the top.
  static int _next(int level) => (level + 1) % (maxLevel + 1);

  CabinClimate copyWith({
    double? temperature,
    int? fanSpeed,
    int? seatRecline,
    int? seatHeat,
    bool? isAcOn,
  }) {
    return CabinClimate(
      temperature: temperature ?? this.temperature,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      seatRecline: seatRecline ?? this.seatRecline,
      seatHeat: seatHeat ?? this.seatHeat,
      isAcOn: isAcOn ?? this.isAcOn,
    );
  }

  @override
  List<Object?> get props => [
    temperature,
    fanSpeed,
    seatRecline,
    seatHeat,
    isAcOn,
  ];
}
