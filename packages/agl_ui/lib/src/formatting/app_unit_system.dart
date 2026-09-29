import 'package:agl_ui/src/formatting/temperature_unit.dart';

/// Which family of units the app reports measurements in.
///
/// Picked in settings and applied wherever a measurement is shown, so a
/// card and the panel it opens onto never disagree about the scale.
///
/// Readings are carried around in metric — the units the forecast service
/// answers in — and converted here at the point they are drawn, so
/// switching systems restates what is already on screen instead of sending
/// the app back to the network for it.
enum AppUnitSystem {
  /// Celsius and km/h.
  international(
    label: 'International System',
    temperatureUnit: TemperatureUnit.celsius,
    windSpeedLabel: 'km/h',
  ),

  /// Fahrenheit and mph.
  imperial(
    label: 'Imperial',
    temperatureUnit: TemperatureUnit.fahrenheit,
    windSpeedLabel: 'mph',
  );

  const AppUnitSystem({
    required this.label,
    required this.temperatureUnit,
    required this.windSpeedLabel,
  });

  /// The human-readable name shown in the settings picker.
  final String label;

  /// The scale this system writes temperatures on.
  final TemperatureUnit temperatureUnit;

  /// How this system's wind speeds are written out, e.g. `km/h`.
  final String windSpeedLabel;

  /// How many miles there are in a kilometer.
  static const _milesPerKilometer = 0.621371;

  /// [celsius] on this system's temperature scale.
  double temperature(double celsius) => switch (this) {
    AppUnitSystem.international => celsius,
    AppUnitSystem.imperial => celsius * 9 / 5 + 32,
  };

  /// [kilometersPerHour] in this system's speed unit.
  double windSpeed(double kilometersPerHour) => switch (this) {
    AppUnitSystem.international => kilometersPerHour,
    AppUnitSystem.imperial => kilometersPerHour * _milesPerKilometer,
  };

  /// A wind speed written the way this system writes it, unit included.
  String formatWindSpeed(double kilometersPerHour) =>
      '${windSpeed(kilometersPerHour).round()} $windSpeedLabel';

  /// One reading written in this system, shown beside [label] so the picker
  /// previews the choice rather than only naming it.
  ///
  /// Run through the same conversions the weather panel uses, so the
  /// preview can never drift from what the cards actually show.
  String get example =>
      '${temperature(20).round()}°${temperatureUnit.toAbbr} · '
      '${formatWindSpeed(30)}';
}
