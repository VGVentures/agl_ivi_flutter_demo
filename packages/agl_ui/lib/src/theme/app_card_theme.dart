import 'package:agl_ui/agl_ui.dart';

/// {@template app_card_theme}
/// The single place card theming is defined.
///
/// Every migrated card gets one [AppCardStyle] field here, so adding or
/// retheming a card is a one line change rather than a new
/// [ThemeExtension]. Read it with `context.appCardTheme` and hand the style
/// to [AppCard].
/// {@endtemplate}
@immutable
class AppCardTheme extends ThemeExtension<AppCardTheme> {
  /// {@macro app_card_theme}
  const AppCardTheme({
    required this.calendar,
    required this.weather,
    required this.evRange,
    required this.settings,
  });

  /// The style used by [CurrentTimeCard].
  final AppCardStyle calendar;

  /// The style used by [WeatherCard].
  final AppCardStyle weather;

  final AppCardStyle evRange;

  /// The style used by the settings overlay opened from the HVAC panel.
  final AppCardStyle settings;

  @override
  AppCardTheme copyWith({
    AppCardStyle? calendar,
    AppCardStyle? weather,
    AppCardStyle? evRange,
    AppCardStyle? settings,
  }) {
    return AppCardTheme(
      calendar: calendar ?? this.calendar,
      weather: weather ?? this.weather,
      evRange: evRange ?? this.evRange,
      settings: settings ?? this.settings,
    );
  }

  @override
  AppCardTheme lerp(covariant ThemeExtension<AppCardTheme>? other, double t) {
    if (other is! AppCardTheme) return this;
    return AppCardTheme(
      calendar: calendar.lerp(other.calendar, t),
      weather: weather.lerp(other.weather, t),
      evRange: evRange.lerp(other.evRange, t),
      settings: settings.lerp(other.settings, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppCardTheme &&
        other.calendar == calendar &&
        other.weather == weather &&
        other.evRange == evRange &&
        other.settings == settings;
  }

  @override
  int get hashCode => Object.hash(calendar, weather, evRange, settings);
}
