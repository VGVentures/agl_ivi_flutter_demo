import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ivi_vgv_demo/hvac/hvac.dart';
import 'package:agl_ivi_vgv_demo/phone/phone.dart';
import 'package:agl_ivi_vgv_demo/profile/profile.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActiveProfileListener', () {
    late ActiveProfileCubit activeProfileCubit;
    late AppBloc appBloc;
    late DriveModeCubit driveModeCubit;
    late ConnectedPhoneCubit connectedPhoneCubit;
    late CabinClimateCubit cabinClimateCubit;

    Widget subject() {
      // Built here rather than in `setUp`: blocs made outside the widget
      // test's zone would process their work on a queue `pump` never
      // reaches.
      activeProfileCubit = ActiveProfileCubit();
      appBloc = AppBloc();
      driveModeCubit = DriveModeCubit();
      connectedPhoneCubit = ConnectedPhoneCubit();
      cabinClimateCubit = CabinClimateCubit();
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: activeProfileCubit),
          BlocProvider.value(value: appBloc),
          BlocProvider.value(value: driveModeCubit),
          BlocProvider.value(value: connectedPhoneCubit),
          BlocProvider.value(value: cabinClimateCubit),
        ],
        child: const ActiveProfileListener(
          child: MaterialApp(home: Scaffold()),
        ),
      );
    }

    testWidgets('a selected driver lands on every setting they carry', (
      tester,
    ) async {
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      const profile = DriverProfile.sam;
      activeProfileCubit.select(profile);
      await tester.pumpAndSettle();

      expect(appBloc.state.themeId, profile.themeId);
      expect(appBloc.state.location, profile.location);
      expect(appBloc.state.timeFormat, profile.timeFormat);
      expect(appBloc.state.unitSystem, profile.unitSystem);
      expect(driveModeCubit.state.mode, profile.driveMode);
      expect(connectedPhoneCubit.state, profile.phone);
      expect(cabinClimateCubit.state.driver, profile.climate);
    });

    testWidgets("a driver profile leaves the passenger's side alone", (
      tester,
    ) async {
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      cabinClimateCubit.cycleSeatHeat(CabinSide.passenger);
      activeProfileCubit.select(DriverProfile.lars);
      await tester.pumpAndSettle();

      expect(cabinClimateCubit.state.passenger.seatHeat, 1);
      expect(
        cabinClimateCubit.state.driver,
        DriverProfile.lars.climate,
      );
    });

    testWidgets('switching drivers again moves everything a second time', (
      tester,
    ) async {
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      activeProfileCubit.select(DriverProfile.sam);
      await tester.pumpAndSettle();
      activeProfileCubit.select(DriverProfile.mei);
      await tester.pumpAndSettle();

      expect(appBloc.state.themeId, DriverProfile.mei.themeId);
      expect(driveModeCubit.state.mode, DriverProfile.mei.driveMode);
      expect(connectedPhoneCubit.state, DriverProfile.mei.phone);
    });
  });
}
