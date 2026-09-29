import 'package:agl_ivi_vgv_demo/hvac/hvac.dart';
import 'package:agl_ivi_vgv_demo/profile/profile.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActiveProfileCubit', () {
    test('starts on the driver the home screen was designed with', () {
      expect(ActiveProfileCubit().state, DriverProfile.jorge);
    });

    blocTest<ActiveProfileCubit, DriverProfile>(
      'select hands the car to the driver',
      build: ActiveProfileCubit.new,
      act: (cubit) => cubit.select(DriverProfile.sam),
      expect: () => [DriverProfile.sam],
    );

    blocTest<ActiveProfileCubit, DriverProfile>(
      'selecting drops whoever had the car before',
      build: ActiveProfileCubit.new,
      act: (cubit) => cubit
        ..select(DriverProfile.sam)
        ..select(DriverProfile.mei),
      expect: () => [DriverProfile.sam, DriverProfile.mei],
    );
  });

  group('DriverProfile', () {
    test('no two profiles leave the car looking the same', () {
      // A profile that agreed with another on everything would make
      // switching between the two look like nothing happened, which is the
      // one thing the panel exists to show.
      final settings = DriverProfile.values
          .map(
            (profile) => [
              profile.themeId,
              profile.location,
              profile.timeFormat,
              profile.unitSystem,
              profile.driveMode,
              profile.phone,
              profile.climate,
            ].join('|'),
          )
          .toSet();

      expect(settings, hasLength(DriverProfile.values.length));
    });

    test('between them the profiles cover both themes', () {
      // Theme is the loudest thing a profile changes; a list that only
      // carried one would never show it changing.
      expect(
        DriverProfile.values.map((profile) => profile.themeId).toSet(),
        hasLength(greaterThan(1)),
      );
    });

    test('every cabin preset is one the controls can actually reach', () {
      for (final profile in DriverProfile.values) {
        final climate = profile.climate;
        expect(
          climate.temperature,
          inInclusiveRange(
            CabinClimate.minTemperature,
            CabinClimate.maxTemperature,
          ),
        );
        for (final level in [
          climate.fanSpeed,
          climate.seatHeat,
          climate.seatRecline,
        ]) {
          expect(level, inInclusiveRange(0, CabinClimate.maxLevel));
        }
      }
    });
  });
}
