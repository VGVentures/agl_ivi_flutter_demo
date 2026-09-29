part of 'weather_forecast_bloc.dart';

sealed class WeatherForecastState extends Equatable {
  const WeatherForecastState();

  @override
  List<Object> get props => [];
}

final class WeatherForecastLoading extends WeatherForecastState {
  const WeatherForecastLoading();
}

final class WeatherForecastLoadFailed extends WeatherForecastState {
  const WeatherForecastLoadFailed();
}

final class WeatherForecastLoadSuccess extends WeatherForecastState {
  const WeatherForecastLoadSuccess({
    required this.location,
    required this.forecast,
  });

  /// The city the forecast was fetched for, so the panel names the place
  /// the days on it actually belong to.
  final AppLocation location;

  final Forecast forecast;

  @override
  List<Object> get props => [location, forecast];
}
