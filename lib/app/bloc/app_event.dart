part of 'app_bloc.dart';

@immutable
sealed class AppEvent {}

final class ThemeSelected extends AppEvent {
  ThemeSelected(this.themeId);

  final AppThemeId themeId;
}

final class LocationSelected extends AppEvent {
  LocationSelected(this.location);

  final AppLocation location;
}

final class TimeFormatSelected extends AppEvent {
  TimeFormatSelected(this.timeFormat);

  final AppTimeFormat timeFormat;
}

final class UnitSystemSelected extends AppEvent {
  UnitSystemSelected(this.unitSystem);

  final AppUnitSystem unitSystem;
}
