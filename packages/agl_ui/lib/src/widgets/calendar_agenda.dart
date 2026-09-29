import 'package:agl_ui/agl_ui.dart';

/// One row in a day's agenda, styled after an in-car calendar list: a
/// colored spine on the leading edge, the event's [title] and optional
/// [subtitle] filling the row, and the time range stacked on the trailing
/// edge.
///
/// Only [accentColor] is passed in, since that belongs to the event's
/// calendar rather than to the app's theme. Everything else is drawn from
/// the ambient text color, the way [PanelSurface] is.
class CalendarEventTile extends StatelessWidget {
  const CalendarEventTile({
    required this.accentColor,
    required this.title,
    required this.startLabel,
    required this.endLabel,
    this.subtitle,
    this.dimmed = false,
    this.highlighted = false,
    super.key,
  });

  /// The color of the leading spine, identifying the event's calendar.
  final Color accentColor;

  /// The event's name.
  final String title;

  /// The event's start time, already formatted for display.
  final String startLabel;

  /// The event's end time, already formatted for display.
  final String endLabel;

  /// Where the event takes place, or `null` to show only the [title].
  final String? subtitle;

  /// Fades the whole row, marking an event that has already finished.
  final bool dimmed;

  /// Lifts the row's surface, marking the event happening right now.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final subtitleStyle = textTheme.bodySmall?.copyWith(
      color: foreground.withValues(alpha: 0.6),
    );

    return Opacity(
      opacity: dimmed ? 0.45 : 1,
      child: PanelSurface(
        emphasized: highlighted,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 5,
                margin: EdgeInsets.symmetric(
                  vertical: context.appSpacing.sm,
                  horizontal: context.appSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.appSpacing.md,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: context.appSpacing.xxs),
                        Text(
                          subtitle!,
                          style: subtitleStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  context.appSpacing.sm,
                  context.appSpacing.md,
                  context.appSpacing.md,
                  context.appSpacing.md,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(startLabel, style: textTheme.titleSmall),
                    Text(endLabel, style: subtitleStyle),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The summary row that sits above a day's events, reporting how many of
/// them run all day.
///
/// Rendered as a pill so it reads as a header for the list rather than an
/// event in it.
class CalendarAllDayBanner extends StatelessWidget {
  const CalendarAllDayBanner({required this.label, super.key});

  /// The text shown inside the pill.
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return PanelSurface(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.appSpacing.lg,
          vertical: context.appSpacing.sm,
        ),
        child: Text(
          label,
          style: textTheme.titleSmall?.copyWith(
            color: foreground.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
