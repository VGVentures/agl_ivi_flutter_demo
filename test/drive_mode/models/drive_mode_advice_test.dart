import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_repository/weather_repository.dart';

/// A reading at [temperature] degrees under the sky [code] stands for, on
/// the WMO scale the repository reports.
Weather _weather({required double temperature, required double code}) =>
    Weather(temperature: temperature, weatherCode: code);

void main() {
  group('DriveModeAdvice', () {
    const clear = 0.0;
    const drizzle = 51.0;
    const rain = 61.0;
    const snow = 71.0;

    test('says nothing before a reading has arrived', () {
      expect(DriveModeAdvice.forWeather(null), isNull);
    });

    test('says nothing on an ordinary day', () {
      expect(
        DriveModeAdvice.forWeather(_weather(temperature: 14, code: clear)),
        isNull,
      );
      expect(
        DriveModeAdvice.forWeather(_weather(temperature: 14, code: rain)),
        isNull,
      );
    });

    test('points at Snow while snow is falling, however mild', () {
      final advice = DriveModeAdvice.forWeather(
        _weather(temperature: 3, code: snow),
      );

      expect(advice?.mode, DriveMode.snow);
      expect(advice?.reason, 'SNOW FALLING');
    });

    test('points at Snow when the road is cold enough to ice', () {
      final advice = DriveModeAdvice.forWeather(
        _weather(temperature: 1, code: clear),
      );

      expect(advice?.mode, DriveMode.snow);
      expect(advice?.reason, 'ROADS NEAR FREEZING');
    });

    test('points at Snow when rain is falling into near-freezing air', () {
      for (final code in [rain, drizzle]) {
        final advice = DriveModeAdvice.forWeather(
          _weather(temperature: 3.5, code: code),
        );

        expect(advice?.mode, DriveMode.snow);
        expect(advice?.reason, 'FREEZING RAIN LIKELY');
      }
    });

    test('leaves cold but dry weather alone', () {
      // Three degrees and clear is a cold morning, not a reason to take
      // power off the line: a badge shown on every winter day is one the
      // driver stops seeing.
      expect(
        DriveModeAdvice.forWeather(_weather(temperature: 3.5, code: clear)),
        isNull,
      );
    });
  });
}
