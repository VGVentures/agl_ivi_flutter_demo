import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:weather_repository/weather_repository.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> bootstrap(
  FutureOr<Widget> Function(WeatherRepository) builder,
) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  // Loads the tz database the calendar reads the selected city's clock
  // from. Bundled with the package, so this needs no network.
  tz.initializeTimeZones();

  // Add cross-flavor configuration here
  final openMeteoApiClient = OpenMeteoApiClient();
  final weatherRepository = WeatherRepository(openMeteoApiClient);
  runApp(await builder(weatherRepository));
}
