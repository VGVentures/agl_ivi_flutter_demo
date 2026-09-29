/// Identifies one of the app's available themes, resolved via
/// `AppTheme.themeFor`.
enum AppThemeId { rainbow, earthy }

/// Display name for [AppThemeId], used by the settings theme picker.
extension AppThemeIdLabel on AppThemeId {
  /// The human-readable name shown in the theme picker.
  String get label => switch (this) {
    AppThemeId.rainbow => 'Rainbow',
    AppThemeId.earthy => 'Earthy',
  };
}
