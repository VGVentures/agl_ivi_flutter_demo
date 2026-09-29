import 'package:agl_ui/agl_ui.dart';

/// {@template app_text_styles}
/// Typography system template. Subject to change based on project Figma specs.
/// {@endtemplate}
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  /// {@macro app_text_styles}
  const AppTextStyles();

  // When a custom font is registered in pubspec.yaml, add
  // `fontFamily: 'YourFontFamily'` to each TextStyle below.

  /// Display Large: 48px, Bold, lineHeight: 56, letterSpacing: -2
  static const TextStyle displayLarge = TextStyle(
    fontSize: 64,
    fontWeight: FontWeight.w700,
    height: 1.17,
    letterSpacing: -2,
  );

  /// Display Medium: 40px, Bold, lineHeight: 48, letterSpacing: -1.5
  static const TextStyle displayMedium = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -1.5,
  );

  /// Display Small: 36px, Bold, lineHeight: 44, letterSpacing: -1.5
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.22,
    letterSpacing: -1.5,
  );

  /// Headline Large: 32px, SemiBold, lineHeight: 40, spacing: -1.5
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -1.5,
  );

  /// Headline Medium: 24px, SemiBold, lineHeight: 32, spacing: -1
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: -1,
  );

  /// Headline Small: 20px, SemiBold, lineHeight: 28, spacing: -0.75
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.75,
  );

  /// Title Large: 24px, Medium, lineHeight: 32, letterSpacing: -0.5
  static const TextStyle titleLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: -0.5,
  );

  /// Title Medium: 20px, Medium, lineHeight: 28, letterSpacing: -0.5
  static const TextStyle titleMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.5,
  );

  /// Title Small: 16px, Medium, lineHeight: 24, letterSpacing: -0.25
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: -0.25,
  );

  /// Label Large: 16px, Medium, lineHeight: 20, letterSpacing: -0.15
  static const TextStyle labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.25,
    letterSpacing: -0.15,
  );

  /// Label Medium: 12px, Medium, lineHeight: 16, letterSpacing: -0.15
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: -0.15,
  );

  /// Label Small: 11px, Medium, lineHeight: 16, letterSpacing: -0.15
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: -0.15,
  );

  /// Body Large: 16px, Medium, lineHeight: 24, letterSpacing: -0.15
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: -0.15,
  );

  /// Body Medium: 14px, Medium, lineHeight: 20, letterSpacing: -0.15
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: -0.15,
  );

  /// Body Small: 12px, Medium, lineHeight: 16, letterSpacing: -0.15
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: -0.15,
  );

  /// Returns the  TextTheme
  static TextTheme get textTheme => const TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
  );

  /// ============ THEME EXTENSION ============
  @override
  AppTextStyles copyWith() => this;

  @override
  AppTextStyles lerp(AppTextStyles? other, double t) => this;
}
