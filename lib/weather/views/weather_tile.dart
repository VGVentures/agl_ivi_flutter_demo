import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/weather/bloc/weather_tile_bloc.dart';
import 'package:agl_ivi_vgv_demo/weather/models/weather_condition_treatment.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class WeatherTile extends StatelessWidget {
  const WeatherTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final location = context.read<AppBloc>().state.location;
        return WeatherTileBloc(
          context.read<WeatherRepository>(),
          location: location,
        )..add(WeatherTileRequested(location));
      },
      child: const WeatherTileView(),
    );
  }
}

class WeatherTileView extends StatelessWidget {
  const WeatherTileView({super.key});

  @override
  Widget build(BuildContext context) {
    // The city of reference lives in [AppBloc] alongside the theme, so a
    // pick in settings reaches the tile the same way a theme change does.
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) => previous.location != current.location,
      listener: (context, state) => context.read<WeatherTileBloc>().add(
        WeatherTileRequested(state.location),
      ),
      child: BlocBuilder<WeatherTileBloc, WeatherTileState>(
        builder: (context, state) {
          final weather = state.weather;
          // Readings are fetched in Celsius and converted here, so picking
          // another unit system restates the card rather than re-reading it.
          final unitSystem = context.select<AppBloc, AppUnitSystem>(
            (bloc) => bloc.state.unitSystem,
          );
          // The card is drawn the same whether or not a reading has landed,
          // so one arriving changes the temperature on it and nothing else.
          return WeatherCard(
            city: state.location.label,
            temperature: weather == null
                ? null
                : unitSystem.temperature(weather.temperature).round(),
            temperatureUnit: unitSystem.temperatureUnit,
            weatherTreatment: weather?.weatherCondition.treatment,
          );
        },
      ),
    );
  }
}
