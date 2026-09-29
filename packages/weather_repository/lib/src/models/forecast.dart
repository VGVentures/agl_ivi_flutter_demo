import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

/// A place's weather now and over the days ahead.
class Forecast extends Equatable {
  const Forecast({required this.current, required this.days});

  /// Conditions right now.
  final Weather current;

  /// The days covered, today first.
  final List<DailyForecast> days;

  /// Today's entry, which the current reading belongs to.
  DailyForecast get today => days.first;

  /// The coldest low across the whole forecast — the floor a chart of the
  /// days measures against, so every day's range is drawn on one scale
  /// rather than each on its own.
  double get low => days.map((day) => day.low).reduce(math.min);

  /// The warmest high across the whole forecast.
  double get high => days.map((day) => day.high).reduce(math.max);

  @override
  List<Object?> get props => [current, days];
}
