/// Icon sizes shared across the app, so panels that sit side by side cannot
/// drift apart.
abstract final class AppIconSizes {
  /// The icons in the permanent controls strip along the bottom: the HVAC
  /// panels on either side and the menu panel between them.
  ///
  /// Wrapped in a default `IconButton`, this gives every one of them the
  /// same touch target.
  static const double control = 35;
}
