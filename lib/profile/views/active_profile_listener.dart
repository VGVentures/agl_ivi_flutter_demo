import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ivi_vgv_demo/hvac/hvac.dart';
import 'package:agl_ivi_vgv_demo/phone/phone.dart';
import 'package:agl_ivi_vgv_demo/profile/cubit/active_profile_cubit.dart';
import 'package:agl_ivi_vgv_demo/profile/models/driver_profile.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Pushes the selected [DriverProfile] into everything it sets.
///
/// The one place that knows a profile is more than a name. [ActiveProfileCubit]
/// holds only the selection, and the theme, the city, the clock, the units,
/// the drive mode, the paired phone and the cabin each stay owned by the
/// bloc that already owned them — so every one of them is still free to be
/// changed by hand afterwards, and nothing has to be routed through the
/// profile to get there.
///
/// Sits above the app shell, where all of those blocs are in reach, so
/// picking a driver in the profile panel lands on cards the panel is
/// covering at the time.
class ActiveProfileListener extends StatelessWidget {
  const ActiveProfileListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActiveProfileCubit, DriverProfile>(
      listener: _apply,
      child: child,
    );
  }

  void _apply(BuildContext context, DriverProfile profile) {
    context.read<AppBloc>()
      ..add(ThemeSelected(profile.themeId))
      ..add(LocationSelected(profile.location))
      ..add(TimeFormatSelected(profile.timeFormat))
      ..add(UnitSystemSelected(profile.unitSystem));
    context.read<DriveModeCubit>().select(profile.driveMode);
    context.read<ConnectedPhoneCubit>().connect(profile.phone);
    // The driver's side only: a driver profile says nothing about how the
    // passenger likes to sit.
    context.read<CabinClimateCubit>().apply(profile.climate);
  }
}
