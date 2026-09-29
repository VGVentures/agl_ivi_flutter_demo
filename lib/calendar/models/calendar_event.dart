import 'package:agl_ui/agl_ui.dart';
import 'package:equatable/equatable.dart';

/// A single entry on the driver's agenda.
///
/// [start] and [end] are wall-clock times within one day; the day itself
/// comes from whichever date the agenda is built for, so the demo's events
/// always land on today.
class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.title,
    required this.start,
    required this.end,
    required this.accentColor,
    this.location,
  });

  /// The event's name.
  final String title;

  /// When the event begins.
  final TimeOfDay start;

  /// When the event ends.
  final TimeOfDay end;

  /// Where the event takes place, or `null` if it has no location.
  final String? location;

  /// Identifies the calendar the event belongs to.
  ///
  /// This is content rather than theming — a real calendar app colors each
  /// event by the calendar it came from — so it travels with the event
  /// instead of living in [AppCardTheme].
  final Color accentColor;

  /// Whether [now] falls between [start] and [end].
  bool isHappeningAt(TimeOfDay now) =>
      !_isBefore(now, start) && _isBefore(now, end);

  /// Whether the event had already finished by [now].
  bool hasEndedBy(TimeOfDay now) => !_isBefore(now, end);

  /// [start] written in [format], e.g. `9:00 AM`.
  String startLabel(AppTimeFormat format) => format.formatTimeOfDay(start);

  /// [end] written in [format], e.g. `10:00 AM`.
  String endLabel(AppTimeFormat format) => format.formatTimeOfDay(end);

  static bool _isBefore(TimeOfDay a, TimeOfDay b) =>
      a.hour * 60 + a.minute < b.hour * 60 + b.minute;

  @override
  List<Object?> get props => [title, start, end, location, accentColor];
}

/// The agenda the Calendar overlay shows.
///
/// Fixed sample content standing in for a real calendar integration. The
/// times are wall-clock only, so the list reads as "today" whenever the
/// demo runs.
const demoAgenda = <CalendarEvent>[
  CalendarEvent(
    title: 'Artist workshop kickoff',
    start: TimeOfDay(hour: 9, minute: 0),
    end: TimeOfDay(hour: 10, minute: 0),
    location: 'Studio B',
    accentColor: _CalendarColors.work,
  ),
  CalendarEvent(
    title: 'Academic advising',
    start: TimeOfDay(hour: 10, minute: 0),
    end: TimeOfDay(hour: 10, minute: 30),
    location: 'Hall 2, Room 114',
    accentColor: _CalendarColors.work,
  ),
  CalendarEvent(
    title: 'Stretching + weights',
    start: TimeOfDay(hour: 11, minute: 0),
    end: TimeOfDay(hour: 13, minute: 0),
    location: 'Kreuzberg Gym',
    accentColor: _CalendarColors.personal,
  ),
  CalendarEvent(
    title: 'Keynote by Jasmine',
    start: TimeOfDay(hour: 14, minute: 30),
    end: TimeOfDay(hour: 15, minute: 45),
    location: 'Auditorium',
    accentColor: _CalendarColors.work,
  ),
  CalendarEvent(
    title: 'Pick up Noah from school',
    start: TimeOfDay(hour: 16, minute: 15),
    end: TimeOfDay(hour: 16, minute: 45),
    location: 'Grundschule am Park',
    accentColor: _CalendarColors.family,
  ),
  CalendarEvent(
    title: 'Charge stop + groceries',
    start: TimeOfDay(hour: 17, minute: 0),
    end: TimeOfDay(hour: 17, minute: 40),
    location: 'Ionity Tempelhof',
    accentColor: _CalendarColors.personal,
  ),
  CalendarEvent(
    title: 'Dinner with the Hartmanns',
    start: TimeOfDay(hour: 19, minute: 30),
    end: TimeOfDay(hour: 21, minute: 30),
    location: 'Katz Orange',
    accentColor: _CalendarColors.family,
  ),
];

/// The all-day entries summarized above [demoAgenda].
const demoAllDayEventCount = 2;

/// One color per calendar the demo's events belong to.
///
/// Saturated enough to stay legible against both the bright and the dark
/// calendar card backgrounds the app themes define.
abstract final class _CalendarColors {
  static const work = Color(0xFFFF3B30);
  static const personal = Color(0xFF0A84FF);
  static const family = Color(0xFFAF52DE);
}
