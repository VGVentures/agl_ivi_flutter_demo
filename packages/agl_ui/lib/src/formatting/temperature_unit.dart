/// The scale a temperature is written on.
///
/// Picked by the app's unit system rather than chosen per card, so
/// every reading on screen is on the same scale.
enum TemperatureUnit {
  celsius,
  fahrenheit;

  String get toAbbr => switch (this) {
    TemperatureUnit.celsius => 'C',
    TemperatureUnit.fahrenheit => 'F',
  };
}
