import 'package:agl_ivi_vgv_demo/powertrain/models/trip.dart';
import 'package:equatable/equatable.dart';

/// {@template powertrain_telemetry}
/// What the battery and the powertrain are doing: the readings behind the
/// Efficiency, EV Range and Boost cards, and behind the panel all three
/// open onto.
///
/// One value rather than a cubit per card, because nothing in the demo
/// moves these figures — unlike the drive mode, which the driver picks, or
/// the forecast, which arrives over the network. There is no state to
/// keep, only one set of readings the three cards and their panel must
/// agree on. A car would feed [demo] from the vehicle bus and leave
/// everything reading it alone.
///
/// Range is deliberately not here: what the pack is worth in miles depends
/// on how the car is being driven, so it is quoted from `DriveModeState`,
/// which is where the driver changes it.
/// {@endtemplate}
final class PowertrainTelemetry extends Equatable {
  /// {@macro powertrain_telemetry}
  const PowertrainTelemetry({
    required this.batteryPercent,
    required this.packKwh,
    required this.trips,
    required this.boostPsi,
    required this.boostPeakPsi,
  });

  /// The readings the demo ships with.
  ///
  /// The five trips are the ones the Efficiency card was drawn with; the
  /// distances are what turns each bar from a number into a rate.
  static const demo = PowertrainTelemetry(
    batteryPercent: 67,
    packKwh: 75,
    trips: [
      Trip(label: '07/28', batteryPercent: 41, miles: 128),
      Trip(label: '08/02', batteryPercent: 53, miles: 152),
      Trip(label: '08/04', batteryPercent: 35, miles: 121),
      Trip(label: '08/11', batteryPercent: 24, miles: 89),
      Trip(label: '08/12', batteryPercent: 12, miles: 47),
    ],
    boostPsi: 8.41,
    boostPeakPsi: 12.6,
  );

  /// How full the pack is, as a whole percentage.
  final int batteryPercent;

  /// What the pack holds when full, in usable kilowatt hours.
  final double packKwh;

  /// The trips the efficiency chart plots, oldest first.
  final List<Trip> trips;

  /// What the compressor is making right now, in psi.
  final double boostPsi;

  /// The highest it has made on this trip, in psi.
  final double boostPeakPsi;

  /// The bottom of the boost gauge: full vacuum, off the throttle.
  static const vacuumPsi = -10.0;

  /// The top of the boost gauge, where the wastegate holds it.
  static const maxBoostPsi = 14.5;

  /// What is left in the pack, in kilowatt hours.
  double get energyRemainingKwh => packKwh * batteryPercent / 100;

  /// How far every trip plotted went in total, in miles.
  int get totalMiles => trips.fold(0, (total, trip) => total + trip.miles);

  /// What those trips spent in total, in kilowatt hours.
  double get totalEnergyKwh =>
      trips.fold(0, (total, trip) => total + trip.energyKwh(packKwh));

  /// How far the car went on each kilowatt hour across every trip plotted.
  ///
  /// Taken over the totals rather than as the mean of the per-trip rates,
  /// so a short errand does not count for as much as a long drive.
  double get averageMilesPerKwh =>
      totalEnergyKwh == 0 ? 0 : totalMiles / totalEnergyKwh;

  /// The best kilowatt hour the car has had, out of the trips plotted.
  double get bestMilesPerKwh => trips.isEmpty
      ? 0
      : trips
            .map((trip) => trip.milesPerKwh(packKwh))
            .reduce((a, b) => a > b ? a : b);

  @override
  List<Object?> get props => [
    batteryPercent,
    packKwh,
    trips,
    boostPsi,
    boostPeakPsi,
  ];
}
