import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

void main() {
  group('AppLocation', () {
    setUpAll(tz.initializeTimeZones);

    // Noon UTC in midsummer, when every city below is on daylight saving
    // time except Tokyo, which never observes it.
    final summerNoon = DateTime.utc(2026, 7, 1, 12);

    test('localTime reads an instant on the city clock', () {
      expect(AppLocation.berlin.localTime(summerNoon).hour, 14);
      expect(AppLocation.newYork.localTime(summerNoon).hour, 8);
      expect(AppLocation.sanFrancisco.localTime(summerNoon).hour, 5);
      expect(AppLocation.tokyo.localTime(summerNoon).hour, 21);
    });

    test('localTime follows daylight saving', () {
      final winterNoon = DateTime.utc(2026, 1, 1, 12);
      expect(AppLocation.berlin.localTime(winterNoon).hour, 13);
      expect(AppLocation.newYork.localTime(winterNoon).hour, 7);
      expect(AppLocation.sanFrancisco.localTime(winterNoon).hour, 4);
      expect(AppLocation.tokyo.localTime(winterNoon).hour, 21);
    });

    test('localTime can land on a different calendar day', () {
      // 21:00 in Tokyo on the 1st is still 08:00 in New York that morning,
      // while an instant late in the New York day is already tomorrow there.
      final lateEvening = DateTime.utc(2026, 7, 1, 23);
      expect(AppLocation.newYork.localTime(lateEvening).day, 1);
      expect(AppLocation.tokyo.localTime(lateEvening).day, 2);
    });

    test('coordinates carry the city position', () {
      expect(
        AppLocation.tokyo.coordinates.latitude,
        AppLocation.tokyo.latitude,
      );
      expect(
        AppLocation.tokyo.coordinates.longitude,
        AppLocation.tokyo.longitude,
      );
    });
  });
}
