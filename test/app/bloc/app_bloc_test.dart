import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBloc', () {
    test('initial state is the first available theme', () {
      expect(AppBloc().state, AppState(AppThemeId.values.first));
    });

    blocTest<AppBloc, AppState>(
      'ThemeSelected jumps directly to the given theme id',
      build: AppBloc.new,
      act: (bloc) => bloc.add(ThemeSelected(AppThemeId.earthy)),
      expect: () => [const AppState(AppThemeId.earthy)],
    );

    test('initial location is Berlin', () {
      expect(AppBloc().state.location, AppLocation.berlin);
    });

    blocTest<AppBloc, AppState>(
      'LocationSelected jumps directly to the given location',
      build: AppBloc.new,
      act: (bloc) => bloc.add(LocationSelected(AppLocation.tokyo)),
      expect: () => [
        AppState(AppThemeId.values.first, location: AppLocation.tokyo),
      ],
    );

    blocTest<AppBloc, AppState>(
      'LocationSelected keeps the selected theme id',
      build: AppBloc.new,
      act: (bloc) => bloc
        ..add(ThemeSelected(AppThemeId.earthy))
        ..add(LocationSelected(AppLocation.newYork)),
      expect: () => const [
        AppState(AppThemeId.earthy),
        AppState(AppThemeId.earthy, location: AppLocation.newYork),
      ],
    );

    blocTest<AppBloc, AppState>(
      'ThemeSelected keeps the selected location',
      build: AppBloc.new,
      act: (bloc) => bloc
        ..add(LocationSelected(AppLocation.sanFrancisco))
        ..add(ThemeSelected(AppThemeId.earthy)),
      expect: () => [
        AppState(
          AppThemeId.values.first,
          location: AppLocation.sanFrancisco,
        ),
        const AppState(
          AppThemeId.earthy,
          location: AppLocation.sanFrancisco,
        ),
      ],
    );

    test('initial time format is the 24-hour clock', () {
      expect(AppBloc().state.timeFormat, AppTimeFormat.twentyFourHour);
    });

    blocTest<AppBloc, AppState>(
      'TimeFormatSelected jumps directly to the given time format',
      build: AppBloc.new,
      act: (bloc) => bloc.add(TimeFormatSelected(AppTimeFormat.twelveHour)),
      expect: () => [
        AppState(
          AppThemeId.values.first,
          timeFormat: AppTimeFormat.twelveHour,
        ),
      ],
    );

    blocTest<AppBloc, AppState>(
      'TimeFormatSelected keeps the selected theme id and location',
      build: AppBloc.new,
      act: (bloc) => bloc
        ..add(ThemeSelected(AppThemeId.earthy))
        ..add(LocationSelected(AppLocation.tokyo))
        ..add(TimeFormatSelected(AppTimeFormat.twelveHour)),
      expect: () => const [
        AppState(AppThemeId.earthy),
        AppState(AppThemeId.earthy, location: AppLocation.tokyo),
        AppState(
          AppThemeId.earthy,
          location: AppLocation.tokyo,
          timeFormat: AppTimeFormat.twelveHour,
        ),
      ],
    );

    test('initial unit system is the international one', () {
      expect(AppBloc().state.unitSystem, AppUnitSystem.international);
    });

    blocTest<AppBloc, AppState>(
      'UnitSystemSelected jumps directly to the given unit system',
      build: AppBloc.new,
      act: (bloc) => bloc.add(UnitSystemSelected(AppUnitSystem.imperial)),
      expect: () => [
        AppState(
          AppThemeId.values.first,
          unitSystem: AppUnitSystem.imperial,
        ),
      ],
    );

    blocTest<AppBloc, AppState>(
      'UnitSystemSelected keeps every other selection',
      build: AppBloc.new,
      act: (bloc) => bloc
        ..add(ThemeSelected(AppThemeId.earthy))
        ..add(LocationSelected(AppLocation.tokyo))
        ..add(TimeFormatSelected(AppTimeFormat.twelveHour))
        ..add(UnitSystemSelected(AppUnitSystem.imperial)),
      expect: () => const [
        AppState(AppThemeId.earthy),
        AppState(AppThemeId.earthy, location: AppLocation.tokyo),
        AppState(
          AppThemeId.earthy,
          location: AppLocation.tokyo,
          timeFormat: AppTimeFormat.twelveHour,
        ),
        AppState(
          AppThemeId.earthy,
          location: AppLocation.tokyo,
          timeFormat: AppTimeFormat.twelveHour,
          unitSystem: AppUnitSystem.imperial,
        ),
      ],
    );

    blocTest<AppBloc, AppState>(
      'ThemeSelected keeps the last selected theme id',
      build: AppBloc.new,
      act: (bloc) => bloc
        ..add(ThemeSelected(AppThemeId.earthy))
        ..add(ThemeSelected(AppThemeId.rainbow)),
      expect: () => const [
        AppState(AppThemeId.earthy),
        AppState(AppThemeId.rainbow),
      ],
    );
  });
}
