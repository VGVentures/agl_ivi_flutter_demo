import 'package:equatable/equatable.dart';

/// {@template trip}
/// One completed trip, as the efficiency chart plots it.
///
/// Carries only what a car can actually measure — how much of the pack the
/// trip spent, and how far it got on it — and derives everything else, so
/// no figure on the panel can disagree with the bar above it.
/// {@endtemplate}
final class Trip extends Equatable {
  /// {@macro trip}
  const Trip({
    required this.label,
    required this.batteryPercent,
    required this.miles,
  });

  /// How the trip is written along the chart's axis, e.g. `08/12`.
  final String label;

  /// How much of the pack the trip spent, as a whole percentage.
  final int batteryPercent;

  /// How far the trip went, in miles.
  final int miles;

  /// What the trip spent out of a pack holding [packKwh].
  double energyKwh(double packKwh) => packKwh * batteryPercent / 100;

  /// How far the trip went on each kilowatt hour.
  ///
  /// The figure that says whether a trip was driven well, rather than only
  /// how long it was: the chart's tallest bar is its longest trip, not its
  /// most wasteful one.
  double milesPerKwh(double packKwh) {
    final energy = energyKwh(packKwh);
    return energy == 0 ? 0 : miles / energy;
  }

  @override
  List<Object?> get props => [label, batteryPercent, miles];
}
