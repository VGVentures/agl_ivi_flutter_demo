import 'package:agl_ivi_vgv_demo/home/home.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MainStageCubit', () {
    test('initial state is the map', () {
      expect(MainStageCubit().state, MainStageView.map);
    });

    blocTest<MainStageCubit, MainStageView>(
      'toggle switches from the map to the scene',
      build: MainStageCubit.new,
      act: (cubit) => cubit.toggle(),
      expect: () => [MainStageView.scene],
    );

    blocTest<MainStageCubit, MainStageView>(
      'toggle switches back to the map',
      build: MainStageCubit.new,
      act: (cubit) => cubit
        ..toggle()
        ..toggle(),
      expect: () => [MainStageView.scene, MainStageView.map],
    );
  });
}
