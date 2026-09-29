import 'package:agl_ivi_vgv_demo/hvac/hvac.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CabinClimateCubit', () {
    test('both sides start off', () {
      final cubit = CabinClimateCubit();

      expect(cubit.state.driver, const CabinClimate());
      expect(cubit.state.passenger, const CabinClimate());
    });

    blocTest<CabinClimateCubit, CabinClimateState>(
      'setTemperature moves only the side it names',
      build: CabinClimateCubit.new,
      act: (cubit) => cubit.setTemperature(CabinSide.driver, 74),
      expect: () => [
        const CabinClimateState(driver: CabinClimate(temperature: 74)),
      ],
    );

    blocTest<CabinClimateCubit, CabinClimateState>(
      'setTemperature clamps to the range the controls offer',
      build: CabinClimateCubit.new,
      act: (cubit) => cubit
        ..setTemperature(CabinSide.driver, 200)
        ..setTemperature(CabinSide.passenger, -40),
      expect: () => [
        const CabinClimateState(
          driver: CabinClimate(temperature: CabinClimate.maxTemperature),
        ),
        const CabinClimateState(
          driver: CabinClimate(temperature: CabinClimate.maxTemperature),
          passenger: CabinClimate(temperature: CabinClimate.minTemperature),
        ),
      ],
    );

    blocTest<CabinClimateCubit, CabinClimateState>(
      'cycling the fan wraps back to off past the top',
      build: CabinClimateCubit.new,
      act: (cubit) {
        for (var i = 0; i <= CabinClimate.maxLevel; i++) {
          cubit.cycleFanSpeed(CabinSide.driver);
        }
      },
      verify: (cubit) => expect(cubit.state.driver.fanSpeed, 0),
    );

    blocTest<CabinClimateCubit, CabinClimateState>(
      'the two sides are set independently',
      build: CabinClimateCubit.new,
      act: (cubit) => cubit
        ..cycleSeatHeat(CabinSide.driver)
        ..cycleSeatRecline(CabinSide.passenger)
        ..toggleAc(CabinSide.driver),
      verify: (cubit) {
        expect(cubit.state.driver.seatHeat, 1);
        expect(cubit.state.driver.isAcOn, true);
        expect(cubit.state.passenger.seatHeat, 0);
        expect(cubit.state.passenger.seatRecline, 1);
        expect(cubit.state.passenger.isAcOn, false);
      },
    );

    blocTest<CabinClimateCubit, CabinClimateState>(
      'apply lands a whole preset on the driver and leaves the passenger',
      build: CabinClimateCubit.new,
      act: (cubit) => cubit
        ..cycleFanSpeed(CabinSide.passenger)
        ..apply(
          const CabinClimate(temperature: 65, fanSpeed: 3, isAcOn: true),
        ),
      verify: (cubit) {
        expect(
          cubit.state.driver,
          const CabinClimate(temperature: 65, fanSpeed: 3, isAcOn: true),
        );
        expect(cubit.state.passenger.fanSpeed, 1);
      },
    );
  });
}
