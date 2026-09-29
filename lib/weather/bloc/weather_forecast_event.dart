part of 'weather_forecast_bloc.dart';

sealed class WeatherForecastEvent extends Equatable {
  const WeatherForecastEvent();

  @override
  List<Object> get props => [];
}

/// Asks for the forecast at [location], both when the overlay opens and
/// whenever the city is changed in settings while it is open.
final class WeatherForecastRequested extends WeatherForecastEvent {
  const WeatherForecastRequested(this.location);

  final AppLocation location;

  @override
  List<Object> get props => [location];
}
