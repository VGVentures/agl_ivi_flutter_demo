import 'package:agl_ui/agl_ui.dart';

/// {@template app_accent_theme}
/// The accent color used for active/selected indicators in the permanent
/// controls — the HVAC level indicator lights and the menu's home icon.
/// {@endtemplate}
@immutable
class AppAccentTheme extends ThemeExtension<AppAccentTheme> {
  /// {@macro app_accent_theme}
  const AppAccentTheme({required this.color});

  /// The color used to indicate an active state.
  final Color color;

  @override
  AppAccentTheme copyWith({Color? color}) {
    return AppAccentTheme(color: color ?? this.color);
  }

  @override
  AppAccentTheme lerp(
    covariant ThemeExtension<AppAccentTheme>? other,
    double t,
  ) {
    if (other is! AppAccentTheme) return this;
    return AppAccentTheme(color: Color.lerp(color, other.color, t)!);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppAccentTheme && other.color == color;
  }

  @override
  int get hashCode => color.hashCode;
}
