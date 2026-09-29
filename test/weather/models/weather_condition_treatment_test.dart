import 'package:agl_ivi_vgv_demo/weather/weather.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_repository/weather_repository.dart';

void main() {
  group('WeatherCondition.fromCode', () {
    test('folds the WMO scale onto the conditions the panel draws', () {
      expect(WeatherCondition.fromCode(0), WeatherCondition.clear);
      expect(WeatherCondition.fromCode(1), WeatherCondition.partlyCloudy);
      expect(WeatherCondition.fromCode(2), WeatherCondition.partlyCloudy);
      expect(WeatherCondition.fromCode(3), WeatherCondition.cloudy);
      expect(WeatherCondition.fromCode(45), WeatherCondition.foggy);
      expect(WeatherCondition.fromCode(53), WeatherCondition.drizzle);
      expect(WeatherCondition.fromCode(65), WeatherCondition.rainy);
      expect(WeatherCondition.fromCode(82), WeatherCondition.rainy);
      expect(WeatherCondition.fromCode(75), WeatherCondition.snowy);
      expect(WeatherCondition.fromCode(95), WeatherCondition.stormy);
    });

    test('reports a code it does not know rather than guessing', () {
      expect(WeatherCondition.fromCode(-1), WeatherCondition.unknown);
      expect(WeatherCondition.fromCode(4), WeatherCondition.unknown);
      expect(WeatherCondition.fromCode(1000), WeatherCondition.unknown);
    });
  });

  group('WeatherConditionTreatment', () {
    test('every condition has a treatment to draw it with', () {
      for (final condition in WeatherCondition.values) {
        expect(condition.treatment, isA<WeatherTreatment>());
      }
    });

    test('an unknown condition claims nothing about the sky', () {
      expect(WeatherCondition.unknown.treatment, WeatherTreatment.cloudy);
    });

    test('conditions the forecast distinguishes are drawn apart', () {
      expect(
        WeatherCondition.clear.treatment,
        isNot(WeatherCondition.rainy.treatment),
      );
      expect(
        WeatherCondition.snowy.treatment,
        isNot(WeatherCondition.stormy.treatment),
      );
    });
  });
}
