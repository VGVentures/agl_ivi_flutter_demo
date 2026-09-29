import 'package:agl_ivi_vgv_demo/drive_mode/models/drive_mode_settings.dart';
import 'package:agl_ui/agl_ui.dart';

/// What each [DriveMode] does to the car.
///
/// The design system owns how a mode is drawn — its name, its glyph, the
/// silhouette behind the card — and this is where the app says what picking
/// one actually means. Kept apart for the reason `WeatherConditionTreatment`
/// keeps the forecast's vocabulary apart from the app's: `agl_ui` has no
/// business knowing what a throttle map is.
extension DriveModeDynamics on DriveMode {
  /// The one line the panel writes under the mode's name.
  String get summary => switch (this) {
    DriveMode.comfort =>
      'Even throttle, neutral steering, a settled ride. Where the car '
          'sits unless it is told otherwise.',
    DriveMode.eco =>
      'Softest throttle, strongest regen, climate reined in. Buys the '
          'most range out of the same battery.',
    DriveMode.sport =>
      'Sharp throttle, weighted steering, firm damping. Trades range '
          'for how quickly the car answers.',
    DriveMode.snow =>
      'Power taken off the line and the ride left soft, so the tyres '
          'are asked for grip rather than pace.',
    DriveMode.custom =>
      'Set by hand. Moving any of the five below lands here, starting '
          'from wherever the car already was.',
  };

  /// Where this mode leaves the five parameters.
  ///
  /// [DriveMode.custom] has no settings of its own to name — the driver's
  /// are kept in `DriveModeState` — so it reports the baseline, which is
  /// what a custom mode nobody has touched yet is seeded from.
  DriveModeSettings get defaults => switch (this) {
    DriveMode.comfort => _comfort,
    DriveMode.eco => const DriveModeSettings(
      throttle: 0,
      regen: 4,
      steering: 1,
      suspension: 1,
      climate: 0,
    ),
    DriveMode.sport => const DriveModeSettings(
      throttle: 4,
      regen: 1,
      steering: 4,
      suspension: 4,
      climate: 3,
    ),
    DriveMode.snow => const DriveModeSettings(
      throttle: 1,
      regen: 1,
      steering: 2,
      suspension: 0,
      climate: 2,
    ),
    DriveMode.custom => _comfort,
  };

  /// The mode every other one is quoted against, on the panel and in
  /// [DriveModeSettings.rangeFactor].
  ///
  /// Comfort rather than whichever mode the car happens to boot in: a range
  /// figure measured from a moving baseline would say nothing.
  static const DriveMode baseline = DriveMode.comfort;

  static const _comfort = DriveModeSettings(
    throttle: 2,
    regen: 2,
    steering: 2,
    suspension: 2,
    climate: 2,
  );
}
