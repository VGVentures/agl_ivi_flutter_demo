import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weather_repository/weather_repository.dart';

part 'weather_forecast_event.dart';
part 'weather_forecast_state.dart';

/// Loads the multi-day forecast the weather overlay is built from.
///
/// Separate from `WeatherTileBloc` because the two ask for different
/// things: the tile only ever needs the current temperature, and paying for
/// a five day forecast to render one number would slow the home screen
/// down for a panel most drivers never open.
class WeatherForecastBloc
    extends Bloc<WeatherForecastEvent, WeatherForecastState> {
  WeatherForecastBloc(this._weatherRepository)
    : super(const WeatherForecastLoading()) {
    on<WeatherForecastRequested>((event, emit) async {
      emit(const WeatherForecastLoading());
      try {
        final forecast = await _weatherRepository.getForecast(
          latitude: event.location.latitude,
          longitude: event.location.longitude,
        );
        // A response that parsed but carried no days would leave the panel
        // with nothing to draw, so it is reported the same way a failed
        // request is rather than crashing on the missing today.
        if (forecast.days.isEmpty) {
          emit(const WeatherForecastLoadFailed());
          return;
        }
        emit(
          WeatherForecastLoadSuccess(
            location: event.location,
            forecast: forecast,
          ),
        );
      } on Exception catch (_) {
        emit(const WeatherForecastLoadFailed());
      }
    });
  }

  final WeatherRepository _weatherRepository;
}
