import 'package:open_meteo_api/open_meteo_api.dart';

/// One reading of a place's weather now, plus the days ahead of it.
///
/// Both come out of a single Open Meteo request, so the panel that shows
/// them cannot end up with a current temperature and a forecast fetched
/// moments apart.
class Forecast {
  const Forecast({required this.current, required this.days});

  /// Conditions at the time of the request.
  final Weather current;

  /// The days covered by the request, today first.
  final List<DailyWeather> days;
}
