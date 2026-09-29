part of 'drive_mode_cubit.dart';

/// {@template drive_mode_state}
/// Which mode the car is in, and what the driver's own mode is set to.
///
/// [custom] is kept whether or not it is selected, so a set of settings
/// built by hand survives a trip through Sport and is still there on the
/// way back.
/// {@endtemplate}
final class DriveModeState extends Equatable {
  /// {@macro drive_mode_state}
  const DriveModeState({
    this.mode = DriveMode.eco,
    DriveModeSettings? custom,
  }) : custom = custom ?? _seed;

  /// What the driver's own mode starts at before anything is moved: the
  /// baseline, so the first bar they touch moves away from a known middle
  /// rather than from whichever mode they happened to be in.
  static const _seed = DriveModeSettings(
    throttle: 2,
    regen: 2,
    steering: 2,
    suspension: 2,
    climate: 2,
  );

  /// The range the battery is good for in [DriveModeDynamics.baseline], in
  /// miles.
  ///
  /// Fixed here because nothing in the demo models a battery. A car would
  /// take this from the pack's own estimate, and the EV Range card — which
  /// quotes the same figure — would be the one to supply it.
  static const baselineRange = 231;

  /// The mode the car is in.
  final DriveMode mode;

  /// Where the driver has left the five parameters, selected or not.
  final DriveModeSettings custom;

  /// The settings actually in force: a named mode's own, or the driver's.
  DriveModeSettings get settings =>
      mode == DriveMode.custom ? custom : mode.defaults;

  /// What the battery is good for in the selected mode, in miles.
  int get estimatedRange => (baselineRange * settings.rangeFactor).round();

  /// How the selected mode's range compares with the baseline's, as a whole
  /// percentage. Positive buys range, negative spends it.
  int get rangeDeltaPercent => rangeDeltaPercentOf(settings);

  /// [rangeDeltaPercent] for any settings, so the list can quote every mode
  /// without the state having to hold one figure per row.
  static int rangeDeltaPercentOf(DriveModeSettings settings) =>
      ((settings.rangeFactor - 1) * 100).round();

  DriveModeState copyWith({DriveMode? mode, DriveModeSettings? custom}) {
    return DriveModeState(
      mode: mode ?? this.mode,
      custom: custom ?? this.custom,
    );
  }

  @override
  List<Object?> get props => [mode, custom];
}
