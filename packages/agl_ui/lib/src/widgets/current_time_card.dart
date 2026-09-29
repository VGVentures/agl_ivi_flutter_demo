import 'package:agl_ui/agl_ui.dart';
import 'package:intl/intl.dart';

class CurrentTimeCard extends StatelessWidget {
  const CurrentTimeCard(
    this.currentTime, {
    this.timeFormat = AppTimeFormat.twentyFourHour,
    super.key,
  });

  final DateTime currentTime;

  /// How the clock is written, as picked in settings.
  final AppTimeFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return AppCard(
      style: context.appCardTheme.calendar,
      title: currentTime.toDayAndMonth.toUpperCase(),
      content: Text(
        timeFormat.format(currentTime),
        style: ts.displayLarge,
      ),
    );
  }
}

extension on DateTime {
  String get toDayAndMonth => DateFormat('EEEE, MMM d').format(this);
}
