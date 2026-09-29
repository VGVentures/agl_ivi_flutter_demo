import 'package:agl_ui/agl_ui.dart';
import 'package:weather_repository/weather_repository.dart';

/// Maps the repository's conditions onto the design system's treatments.
///
/// The two vocabularies are kept apart on purpose — one belongs to the
/// forecast source, the other to how the app draws weather — and this is
/// the single seam between them.
extension WeatherConditionTreatment on WeatherCondition {
  WeatherTreatment get treatment => switch (this) {
    WeatherCondition.clear => WeatherTreatment.sunny,
    WeatherCondition.partlyCloudy => WeatherTreatment.partlyCloudy,
    WeatherCondition.cloudy => WeatherTreatment.cloudy,
    WeatherCondition.foggy => WeatherTreatment.foggy,
    WeatherCondition.drizzle => WeatherTreatment.drizzle,
    WeatherCondition.rainy => WeatherTreatment.rainy,
    WeatherCondition.snowy => WeatherTreatment.snowy,
    WeatherCondition.stormy => WeatherTreatment.stormy,
    // Nothing is known about the sky, so the panel shows the treatment that
    // claims the least rather than inventing a condition.
    WeatherCondition.unknown => WeatherTreatment.cloudy,
  };
}
