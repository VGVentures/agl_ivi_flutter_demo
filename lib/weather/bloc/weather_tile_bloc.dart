import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_tile_event.dart';
part 'weather_tile_state.dart';

/// Keeps the weather card's reading up to date.
///
/// Updates silently: nothing is emitted when a request starts, so the card
/// never swaps itself out for a spinner the way no other card on the home
/// screen does. A new reading simply replaces the old one when it lands.
class WeatherTileBloc extends Bloc<WeatherTileEvent, WeatherTileState> {
  WeatherTileBloc(this._weatherRepository, {required AppLocation location})
    : super(WeatherTileState(location: location)) {
    on<WeatherTileRequested>(_onRequested);
  }

  final WeatherRepository _weatherRepository;

  Future<void> _onRequested(
    WeatherTileRequested event,
    Emitter<WeatherTileState> emit,
  ) async {
    // A reading only belongs to the city it was taken at: refreshing the
    // same city leaves the temperature up while the new one is fetched,
    // but moving to another city drops it, rather than showing Berlin's
    // temperature under Tokyo's name.
    if (event.location != state.location) {
      emit(WeatherTileState(location: event.location));
    }

    try {
      final weather = await _weatherRepository.getWeather(
        latitude: event.location.latitude,
        longitude: event.location.longitude,
      );
      emit(WeatherTileState(location: event.location, weather: weather));
    } on Exception catch (_) {
      // Nothing to say on the card itself, so the failure is left to the
      // forecast panel to report: the card goes on showing whatever
      // reading it already had, or no reading at all.
    }
  }
}
