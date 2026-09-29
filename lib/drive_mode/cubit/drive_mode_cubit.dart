import 'package:agl_ivi_vgv_demo/drive_mode/models/drive_mode_dynamics.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/models/drive_mode_settings.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'drive_mode_state.dart';

/// {@template drive_mode_cubit}
/// Holds the mode the car is being driven in.
///
/// Provided above `HomeNavigator` rather than inside the Drive Mode card:
/// the card and the panel it opens are in different subtrees, and a cubit
/// per subtree would mean picking Sport in the panel and closing it onto a
/// card that still says Eco.
/// {@endtemplate}
class DriveModeCubit extends Cubit<DriveModeState> {
  /// {@macro drive_mode_cubit}
  DriveModeCubit() : super(const DriveModeState());

  /// Puts the car in [mode].
  ///
  /// Selecting [DriveMode.custom] restores whatever the driver last left
  /// the parameters at rather than resetting them.
  void select(DriveMode mode) => emit(state.copyWith(mode: mode));

  /// Moves [parameter] to [value].
  ///
  /// Always lands in [DriveMode.custom], seeded from the settings already
  /// in force: reaching for a bar while in Sport is a request to drive
  /// something like Sport, not a request to start from the middle. A named
  /// mode is therefore never quietly redefined, and is still there to go
  /// back to.
  void adjust(DriveModeParameter parameter, int value) {
    final adjusted = state.settings.withValue(parameter, value);
    if (state.mode == DriveMode.custom && adjusted == state.custom) return;
    emit(state.copyWith(mode: DriveMode.custom, custom: adjusted));
  }
}
