import 'package:flutter/material.dart' show TimeOfDay;
import 'package:intl/intl.dart';

/// How the app writes clock times.
///
/// Picked in settings and applied everywhere a time is shown, so the clock
/// card and the calendar agenda always read the same way.
enum AppTimeFormat {
  /// A 24-hour clock, e.g. `17:30`.
  twentyFourHour('24-hour'),

  /// A 12-hour clock with an AM/PM suffix, e.g. `5:30 PM`.
  twelveHour('AM/PM');

  const AppTimeFormat(this.label);

  /// The human-readable name shown in the settings picker.
  final String label;

  /// One time written in this format, shown beside [label] so the picker
  /// previews the choice rather than only naming it.
  ///
  /// Run through [format] rather than written out, so the preview can never
  /// drift from what the clock and the agenda actually show.
  String get example => format(DateTime(2000, 1, 1, 17, 30));

  /// The wall-clock time of [dateTime], written in this format.
  String format(DateTime dateTime) => switch (this) {
    AppTimeFormat.twentyFourHour => DateFormat.Hm().format(dateTime),
    // `jm` separates the suffix with a narrow no-break space, which the
    // app's font has no glyph for. An ordinary space reads the same and
    // keeps the string comparable to one written by hand.
    AppTimeFormat.twelveHour =>
      DateFormat.jm().format(dateTime).replaceAll(' ', ' '),
  };

  /// [time] written in this format.
  ///
  /// The date the formatter needs is arbitrary: neither format shows it.
  String formatTimeOfDay(TimeOfDay time) =>
      format(DateTime(2000, 1, 1, time.hour, time.minute));
}
