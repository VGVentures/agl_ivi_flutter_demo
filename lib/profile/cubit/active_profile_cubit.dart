import 'package:agl_ivi_vgv_demo/profile/models/driver_profile.dart';
import 'package:bloc/bloc.dart';

/// {@template active_profile_cubit}
/// Holds which driver the car is set up for.
///
/// Only the selection lives here. What that selection *does* — the theme,
/// the city, the drive mode, the paired phone, the cabin — belongs to the
/// blocs that already own those things, and is pushed into them by
/// `ActiveProfileListener`. Keeping the two apart means a setting changed
/// by hand afterwards is not silently overwritten by a profile that thinks
/// it still owns it.
/// {@endtemplate}
class ActiveProfileCubit extends Cubit<DriverProfile> {
  /// {@macro active_profile_cubit}
  ActiveProfileCubit() : super(DriverProfile.values.first);

  /// Puts the car in [profile]'s hands, dropping whoever had it before.
  ///
  /// A car is driven by one person at a time, so this is a swap rather than
  /// an addition. Selecting the profile already in force does nothing: a
  /// [Cubit] drops an emit that does not change the state, so settings
  /// changed by hand since are left as the driver left them.
  void select(DriverProfile profile) => emit(profile);
}
