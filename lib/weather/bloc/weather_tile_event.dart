part of 'weather_tile_bloc.dart';

sealed class WeatherTileEvent extends Equatable {
  const WeatherTileEvent();

  @override
  List<Object> get props => [];
}

/// Asks for the weather at [location], both when the tile first appears and
/// whenever the city is changed in settings.
final class WeatherTileRequested extends WeatherTileEvent {
  const WeatherTileRequested(this.location);

  final AppLocation location;

  @override
  List<Object> get props => [location];
}
