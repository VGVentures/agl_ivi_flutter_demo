import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTimeFormat', () {
    final afternoon = DateTime(2026, 7, 1, 17, 30);

    test('twentyFourHour writes an afternoon time without a suffix', () {
      expect(AppTimeFormat.twentyFourHour.format(afternoon), '17:30');
    });

    test('twelveHour writes an afternoon time with a PM suffix', () {
      expect(AppTimeFormat.twelveHour.format(afternoon), '5:30 PM');
    });

    test('formatTimeOfDay writes a wall-clock time the same way', () {
      const morning = TimeOfDay(hour: 9, minute: 5);
      expect(AppTimeFormat.twentyFourHour.formatTimeOfDay(morning), '09:05');
      expect(AppTimeFormat.twelveHour.formatTimeOfDay(morning), '9:05 AM');
    });

    test('midnight reads as 00:00 and 12:00 AM', () {
      final midnight = DateTime(2026, 7, 2);
      expect(AppTimeFormat.twentyFourHour.format(midnight), '00:00');
      expect(AppTimeFormat.twelveHour.format(midnight), '12:00 AM');
    });

    test('example previews the format on a fixed time', () {
      expect(AppTimeFormat.twentyFourHour.example, '17:30');
      expect(AppTimeFormat.twelveHour.example, '5:30 PM');
    });

    test('the AM/PM suffix is separated by an ordinary space', () {
      expect(
        AppTimeFormat.twelveHour.format(afternoon),
        isNot(contains('\u202f')),
      );
    });
  });
}
