import 'package:agl_ivi_vgv_demo/home/home.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeViewCubit', () {
    test('initial state is the dashboard', () {
      expect(HomeViewCubit().state, HomeView.dashboard);
    });

    blocTest<HomeViewCubit, HomeView>(
      'toggle switches from the dashboard to the launcher',
      build: HomeViewCubit.new,
      act: (cubit) => cubit.toggle(),
      expect: () => [HomeView.apps],
    );

    blocTest<HomeViewCubit, HomeView>(
      'toggle switches back to the dashboard',
      build: HomeViewCubit.new,
      act: (cubit) => cubit
        ..toggle()
        ..toggle(),
      expect: () => [HomeView.apps, HomeView.dashboard],
    );
  });
}
