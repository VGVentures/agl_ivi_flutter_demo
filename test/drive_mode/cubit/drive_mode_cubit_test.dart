import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriveModeCubit', () {
    test('starts in Eco, the mode the home screen was designed in', () {
      expect(DriveModeCubit().state.mode, DriveMode.eco);
    });

    blocTest<DriveModeCubit, DriveModeState>(
      'select puts the car in the mode',
      build: DriveModeCubit.new,
      act: (cubit) => cubit.select(DriveMode.sport),
      expect: () => const [DriveModeState(mode: DriveMode.sport)],
    );

    blocTest<DriveModeCubit, DriveModeState>(
      'a named mode reports its own settings',
      build: DriveModeCubit.new,
      act: (cubit) => cubit.select(DriveMode.sport),
      verify: (cubit) => expect(
        cubit.state.settings,
        DriveMode.sport.defaults,
      ),
    );

    group('adjust', () {
      blocTest<DriveModeCubit, DriveModeState>(
        'lands in Custom, seeded from the mode already in force',
        build: DriveModeCubit.new,
        seed: () => const DriveModeState(mode: DriveMode.sport),
        act: (cubit) => cubit.adjust(DriveModeParameter.suspension, 0),
        expect: () => [
          DriveModeState(
            mode: DriveMode.custom,
            // Sport throughout, bar the one parameter that was moved: a
            // driver reaching for a bar is asking for something like the
            // mode they are in, not for the middle of everything.
            custom: DriveMode.sport.defaults.copyWith(suspension: 0),
          ),
        ],
      );

      blocTest<DriveModeCubit, DriveModeState>(
        'leaves the named mode it was seeded from alone',
        build: DriveModeCubit.new,
        seed: () => const DriveModeState(mode: DriveMode.sport),
        act: (cubit) => cubit
          ..adjust(DriveModeParameter.throttle, 0)
          ..select(DriveMode.sport),
        verify: (cubit) => expect(
          cubit.state.settings,
          DriveMode.sport.defaults,
        ),
      );

      blocTest<DriveModeCubit, DriveModeState>(
        'keeps the settings built by hand through another mode',
        build: DriveModeCubit.new,
        act: (cubit) => cubit
          ..adjust(DriveModeParameter.regen, 4)
          ..select(DriveMode.sport)
          ..select(DriveMode.custom),
        verify: (cubit) => expect(cubit.state.settings.regen, 4),
      );

      blocTest<DriveModeCubit, DriveModeState>(
        'emits nothing when a bar is dragged onto where it already is',
        build: DriveModeCubit.new,
        seed: () => const DriveModeState(mode: DriveMode.custom),
        act: (cubit) => cubit.adjust(
          DriveModeParameter.throttle,
          const DriveModeState().custom.throttle,
        ),
        expect: () => <DriveModeState>[],
      );

      blocTest<DriveModeCubit, DriveModeState>(
        'clamps a position that does not exist',
        build: DriveModeCubit.new,
        act: (cubit) => cubit.adjust(DriveModeParameter.throttle, 99),
        verify: (cubit) => expect(
          cubit.state.settings.throttle,
          DriveModeParameter.steps - 1,
        ),
      );
    });

    group('range', () {
      test('Comfort is the baseline everything else is quoted against', () {
        const state = DriveModeState(mode: DriveModeDynamics.baseline);
        expect(state.rangeDeltaPercent, 0);
        expect(state.estimatedRange, DriveModeState.baselineRange);
      });

      test('Eco buys range and Sport spends it', () {
        const eco = DriveModeState();
        const sport = DriveModeState(mode: DriveMode.sport);

        expect(eco.rangeDeltaPercent, greaterThan(0));
        expect(sport.rangeDeltaPercent, lessThan(0));
        expect(eco.estimatedRange, greaterThan(sport.estimatedRange));
      });

      test('settings built by hand are quoted the same way a mode is', () {
        // The same positions Eco sits at, reached by hand rather than by
        // selecting it, have to cost exactly what Eco costs.
        final cubit = DriveModeCubit();
        for (final parameter in DriveModeParameter.values) {
          cubit.adjust(parameter, DriveMode.eco.defaults.valueOf(parameter));
        }

        expect(cubit.state.mode, DriveMode.custom);
        expect(
          cubit.state.estimatedRange,
          const DriveModeState().estimatedRange,
        );
      });
    });
  });
}
