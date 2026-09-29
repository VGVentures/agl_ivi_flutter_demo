part of 'weather_tile_bloc.dart';

/// What the weather card is showing.
///
/// One state rather than a loading/success/failure set, because the card
/// has something worth drawing from the moment it appears: the city is
/// known before any request is made, and only the reading has to be waited
/// for. A request in flight is not a state of its own — the card carries on
/// showing what it has while the next reading is on its way.
final class WeatherTileState extends Equatable {
  const WeatherTileState({required this.location, this.weather});

  /// The city the card names, and the one [weather] was taken for.
  final AppLocation location;

  /// The last reading taken at [location], or `null` while none has
  /// arrived yet.
  final Weather? weather;

  @override
  List<Object?> get props => [location, weather];
}
