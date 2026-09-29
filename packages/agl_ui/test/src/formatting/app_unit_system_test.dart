import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUnitSystem', () {
    test('international leaves a Celsius reading alone', () {
      expect(AppUnitSystem.international.temperature(20), 20);
      expect(AppUnitSystem.international.temperature(-8.5), -8.5);
    });

    test('imperial writes a Celsius reading in Fahrenheit', () {
      expect(AppUnitSystem.imperial.temperature(0), 32);
      expect(AppUnitSystem.imperial.temperature(100), 212);
      expect(AppUnitSystem.imperial.temperature(-40), -40);
      expect(AppUnitSystem.imperial.temperature(20), closeTo(68, 0.001));
    });

    test('each system names the scale it writes temperatures on', () {
      expect(
        AppUnitSystem.international.temperatureUnit,
        TemperatureUnit.celsius,
      );
      expect(
        AppUnitSystem.imperial.temperatureUnit,
        TemperatureUnit.fahrenheit,
      );
    });

    test('international leaves a wind speed in km/h', () {
      expect(AppUnitSystem.international.windSpeed(30), 30);
      expect(AppUnitSystem.international.formatWindSpeed(30), '30 km/h');
    });

    test('imperial writes a wind speed in mph', () {
      expect(AppUnitSystem.imperial.windSpeed(0), 0);
      expect(AppUnitSystem.imperial.windSpeed(100), closeTo(62.14, 0.01));
      expect(AppUnitSystem.imperial.formatWindSpeed(30), '19 mph');
    });

    test('example previews the system on a fixed reading', () {
      expect(AppUnitSystem.international.example, '20°C · 30 km/h');
      expect(AppUnitSystem.imperial.example, '68°F · 19 mph');
    });
  });
}
