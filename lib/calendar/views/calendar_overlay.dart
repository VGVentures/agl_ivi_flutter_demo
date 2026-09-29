import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/calendar/bloc/calendar_tile_bloc.dart';
import 'package:agl_ivi_vgv_demo/calendar/models/calendar_event.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

/// The Calendar card's overlay: today's agenda, with the day summarized on
/// the leading side and the events listed beside it.
///
/// Built from [demoAgenda] rather than a real calendar, so the content is
/// fixed while the clock around it is live — events that have already
/// finished dim, and the summary tracks which one comes next.
class CalendarOverlay extends StatelessWidget {
  const CalendarOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Its own instance rather than the tile's: the overlay is pushed on
    // `HomeNavigator`, above the subtree where `CalendarTile` provides one.
    return BlocProvider(
      create: (_) => CalendarTileBloc()..add(const CalendarLaunched()),
      child: const _CalendarOverlayView(),
    );
  }
}

class _CalendarOverlayView extends StatelessWidget {
  const _CalendarOverlayView();

  /// Clears the close button [CardOverlayScaffold] paints over the
  /// content's top-left corner.
  static const _closeButtonClearance = 80.0;

  @override
  Widget build(BuildContext context) {
    // Read on the selected city's wall clock, so the agenda dims and the
    // "up next" entry advance against local time rather than the head
    // unit's.
    final location = context.select<AppBloc, AppLocation>(
      (bloc) => bloc.state.location,
    );
    // Every time on the agenda is written the way settings asks for.
    final timeFormat = context.select<AppBloc, AppTimeFormat>(
      (bloc) => bloc.state.timeFormat,
    );
    return BlocBuilder<CalendarTileBloc, DateTime>(
      builder: (context, instant) {
        final now = location.localTime(instant);
        final time = TimeOfDay.fromDateTime(now);
        return Padding(
          padding: EdgeInsets.fromLTRB(
            context.appSpacing.xlg,
            _closeButtonClearance,
            context.appSpacing.xlg,
            context.appSpacing.lg,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Proportional rather than fixed widths, so the layout still
              // fits while the panel is mid-flight out of the card and only
              // a fraction of its final size.
              Flexible(
                flex: 2,
                child: _DaySummary(
                  now: now,
                  time: time,
                  timeFormat: timeFormat,
                ),
              ),
              SizedBox(width: context.appSpacing.xlg),
              Flexible(
                flex: 5,
                child: _Agenda(time: time, timeFormat: timeFormat),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The leading column: the date, how the day is shaped, and what is coming
/// up next.
class _DaySummary extends StatelessWidget {
  const _DaySummary({
    required this.now,
    required this.time,
    required this.timeFormat,
  });

  final DateTime now;
  final TimeOfDay time;
  final AppTimeFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final upcoming = demoAgenda.where((e) => !e.hasEndedBy(time)).toList();

    // Scrollable so the column clips instead of overflowing when the panel
    // is shorter than its content — during the Hero flight, or on a small
    // window.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('EEEE').format(now),
            style: textTheme.displaySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            DateFormat('MMMM d').format(now),
            style: textTheme.titleMedium?.copyWith(
              color: foreground.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: context.appSpacing.lg),
          const CalendarAllDayBanner(
            label: '$demoAllDayEventCount all-day events',
          ),
          SizedBox(height: context.appSpacing.md),
          _UpNext(
            event: upcoming.isEmpty ? null : upcoming.first,
            time: time,
            timeFormat: timeFormat,
          ),
        ],
      ),
    );
  }
}

/// Names the event happening now, or the one after it once the current one
/// is over.
///
/// Sits on its own [PanelSurface] so the summary column reads as two
/// deliberate blocks rather than text trailing off into empty panel.
class _UpNext extends StatelessWidget {
  const _UpNext({
    required this.event,
    required this.time,
    required this.timeFormat,
  });

  /// The first event that has not finished yet, or `null` once the day's
  /// agenda is done.
  final CalendarEvent? event;

  final TimeOfDay time;

  final AppTimeFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    // The theme's own active-state color, so the label ties the panel back
    // to the card it opened from without either theme needing a token of
    // its own for it.
    final labelStyle = textTheme.labelMedium?.copyWith(
      color: context.appAccentTheme.color,
      letterSpacing: 1.5,
    );

    final event = this.event;
    return PanelSurface(
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.md),
        child: event == null
            ? Text('NOTHING LEFT TODAY', style: labelStyle)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.isHappeningAt(time) ? 'HAPPENING NOW' : 'UP NEXT',
                    style: labelStyle,
                  ),
                  SizedBox(height: context.appSpacing.xs),
                  Text(
                    event.title,
                    style: textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.appSpacing.xxs),
                  Text(
                    '${event.startLabel(timeFormat)} – '
                    '${event.endLabel(timeFormat)}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: foreground.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// The day's events, oldest first, with finished ones faded back.
class _Agenda extends StatelessWidget {
  const _Agenda({required this.time, required this.timeFormat});

  final TimeOfDay time;
  final AppTimeFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: context.appSpacing.lg),
      itemCount: demoAgenda.length,
      separatorBuilder: (_, _) => SizedBox(height: context.appSpacing.xs),
      itemBuilder: (context, index) {
        final event = demoAgenda[index];
        return CalendarEventTile(
          accentColor: event.accentColor,
          title: event.title,
          subtitle: event.location,
          startLabel: event.startLabel(timeFormat),
          endLabel: event.endLabel(timeFormat),
          dimmed: event.hasEndedBy(time),
          highlighted: event.isHappeningAt(time),
        );
      },
    );
  }
}
