import 'package:agl_ivi_vgv_demo/powertrain/powertrain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Trip', () {
    const trip = Trip(label: '08/12', batteryPercent: 20, miles: 75);

    test('spends its share of the pack', () {
      expect(trip.energyKwh(50), 10);
    });

    test('reports what it bought with it', () {
      expect(trip.milesPerKwh(50), 7.5);
    });

    test(
      'a trip that spent nothing has no rate rather than an infinite one',
      () {
        const parked = Trip(label: '08/13', batteryPercent: 0, miles: 0);
        expect(parked.milesPerKwh(50), 0);
      },
    );
  });

  group('PowertrainTelemetry', () {
    const telemetry = PowertrainTelemetry(
      batteryPercent: 50,
      packKwh: 100,
      trips: [
        // 10 kWh for 20 miles: 2 mi/kWh.
        Trip(label: 'A', batteryPercent: 10, miles: 20),
        // 30 kWh for 150 miles: 5 mi/kWh.
        Trip(label: 'B', batteryPercent: 30, miles: 150),
      ],
      boostPsi: 8,
      boostPeakPsi: 12,
    );

    test('reports what is left in the pack', () {
      expect(telemetry.energyRemainingKwh, 50);
    });

    test('totals the trips it plots', () {
      expect(telemetry.totalMiles, 170);
      expect(telemetry.totalEnergyKwh, 40);
    });

    test(
      'averages over the totals, so a long trip counts for more than a short '
      'one',
      () {
        // The mean of the two rates would be 3.5; weighting by the energy
        // each one spent gives the figure the car actually achieved.
        expect(telemetry.averageMilesPerKwh, 4.25);
      },
    );

    test('picks out the best kilowatt hour it has had', () {
      expect(telemetry.bestMilesPerKwh, 5);
    });

    test('an empty history reports nothing rather than dividing by zero', () {
      const empty = PowertrainTelemetry(
        batteryPercent: 50,
        packKwh: 100,
        trips: [],
        boostPsi: 0,
        boostPeakPsi: 0,
      );
      expect(empty.averageMilesPerKwh, 0);
      expect(empty.bestMilesPerKwh, 0);
      expect(empty.totalMiles, 0);
    });
  });
}
