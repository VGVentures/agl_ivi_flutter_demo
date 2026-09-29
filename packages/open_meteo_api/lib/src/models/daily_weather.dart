/// One day of Open Meteo's daily forecast block.
///
/// The API answers a `daily=` request in columns — one array per variable,
/// all aligned by index — so [listFromJson] zips them back into a row per
/// day before anything downstream sees them.
class DailyWeather {
  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbability,
    required this.windSpeed,
    required this.sunrise,
    required this.sunset,
  });

  /// The day this row describes, on the city's own calendar.
  final DateTime date;

  /// The WMO code summarizing the day, on the same scale as the current
  /// weather's.
  final double weatherCode;

  /// The day's high, in the units the request asked for.
  final double temperatureMax;

  /// The day's low, in the units the request asked for.
  final double temperatureMin;

  /// The highest chance of precipitation across the day, as a percentage.
  final int precipitationProbability;

  /// The day's strongest wind, in the units the request asked for.
  final double windSpeed;

  /// Sunrise, on the city's wall clock.
  final DateTime sunrise;

  /// Sunset, on the city's wall clock.
  final DateTime sunset;

  /// Reads Open Meteo's `daily` block into one [DailyWeather] per day.
  ///
  /// The number of days comes from the `time` column, and every other
  /// column is read at that index — a variable the response left out, or
  /// left null for a day, falls back rather than failing the whole block,
  /// since a missing precipitation chance is no reason to lose the
  /// forecast.
  static List<DailyWeather> listFromJson(Map<String, dynamic> json) {
    final dates = (json['time'] as List? ?? []).cast<String>();

    List<num?> column(String name) =>
        (json[name] as List? ?? []).cast<num?>();

    List<String?> textColumn(String name) =>
        (json[name] as List? ?? []).cast<String?>();

    final weatherCodes = column('weathercode');
    final maxima = column('temperature_2m_max');
    final minima = column('temperature_2m_min');
    final precipitation = column('precipitation_probability_max');
    final winds = column('windspeed_10m_max');
    final sunrises = textColumn('sunrise');
    final sunsets = textColumn('sunset');

    T? at<T>(List<T?> column, int index) =>
        index < column.length ? column[index] : null;

    return [
      for (var i = 0; i < dates.length; i++)
        DailyWeather(
          date: DateTime.parse(dates[i]),
          weatherCode: at(weatherCodes, i)?.toDouble() ?? 0,
          temperatureMax: at(maxima, i)?.toDouble() ?? 0,
          temperatureMin: at(minima, i)?.toDouble() ?? 0,
          precipitationProbability: at(precipitation, i)?.toInt() ?? 0,
          windSpeed: at(winds, i)?.toDouble() ?? 0,
          sunrise: DateTime.parse(at(sunrises, i) ?? dates[i]),
          sunset: DateTime.parse(at(sunsets, i) ?? dates[i]),
        ),
    ];
  }
}
