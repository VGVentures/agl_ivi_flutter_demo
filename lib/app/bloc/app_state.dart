part of 'app_bloc.dart';

@immutable
class AppState extends Equatable {
  const AppState(
    this.themeId, {
    this.location = AppLocation.berlin,
    this.timeFormat = AppTimeFormat.twentyFourHour,
    this.unitSystem = AppUnitSystem.international,
  });

  final AppThemeId themeId;

  /// The city the weather, the clock and the map all report on.
  final AppLocation location;

  /// How every clock in the app writes the time.
  final AppTimeFormat timeFormat;

  /// The units the weather card and its panel report readings in.
  final AppUnitSystem unitSystem;

  ThemeData get theme => AppTheme.themeFor(themeId);

  AppState copyWith({
    AppThemeId? themeId,
    AppLocation? location,
    AppTimeFormat? timeFormat,
    AppUnitSystem? unitSystem,
  }) {
    return AppState(
      themeId ?? this.themeId,
      location: location ?? this.location,
      timeFormat: timeFormat ?? this.timeFormat,
      unitSystem: unitSystem ?? this.unitSystem,
    );
  }

  @override
  List<Object?> get props => [themeId, location, timeFormat, unitSystem];
}
