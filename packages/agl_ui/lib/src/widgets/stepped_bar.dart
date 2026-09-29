import 'package:agl_ui/agl_ui.dart';

/// A setting with a handful of positions, drawn as a row of segments.
///
/// Segments up to and including [value] are lit; the rest are left as
/// hollows. The fill sweeps between positions rather than snapping, so a row
/// of these restating themselves at once — the five parameters behind a
/// drive mode, say — reads as one movement.
///
/// Give [onChanged] to make it adjustable: the whole row, including the
/// space above and below the segments, is a target, and a drag along it
/// keeps reporting the segment under the finger. Left null the bar is a
/// readout.
class SteppedBar extends StatelessWidget {
  const SteppedBar({
    required this.steps,
    required this.value,
    this.onChanged,
    this.color,
    this.height = 14,
    this.semanticLabel,
    super.key,
  }) : assert(steps > 1, 'A bar of one segment has nothing to say.');

  /// How long the fill takes to reach a new position.
  static const _sweep = Duration(milliseconds: 420);

  /// How far the target extends above and below the segments, so the bar can
  /// be drawn slim and still be hit at arm's length in a moving car.
  static const _touchPadding = 13.0;

  /// The gap between one segment and the next.
  static const _gap = 5.0;

  /// How much of the foreground an unlit segment keeps, which is enough to
  /// show how many positions are left without competing with the lit ones.
  static const _unlitOpacity = 0.22;

  /// How many positions the setting has.
  final int steps;

  /// The position it is at, from 0 to `steps - 1`.
  final int value;

  /// Called with the position the driver moved it to. Null makes the bar a
  /// readout rather than a control.
  final ValueChanged<int>? onChanged;

  /// The color lit segments are painted in. Defaults to the ambient text
  /// color, which is what a bar on a card overlay wants.
  final Color? color;

  /// How tall the segments are drawn.
  final double height;

  /// Names the setting for assistive technology, e.g. `'Throttle'`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final foreground =
        color ?? Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;

    final bar = LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          // The padding around the segments is part of the target, not a
          // hole in it.
          behavior: HitTestBehavior.opaque,
          onTapDown: onChanged == null
              ? null
              : (details) => _report(details.localPosition, constraints),
          onHorizontalDragStart: onChanged == null
              ? null
              : (details) => _report(details.localPosition, constraints),
          onHorizontalDragUpdate: onChanged == null
              ? null
              : (details) => _report(details.localPosition, constraints),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: _touchPadding),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: value + 1),
              duration: _sweep,
              curve: Curves.easeOutCubic,
              builder: (context, lit, _) => Row(
                children: [
                  for (var i = 0; i < steps; i++) ...[
                    if (i > 0) const SizedBox(width: _gap),
                    Expanded(
                      child: SizedBox(
                        height: height,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: foreground.withValues(
                              // The fill sweeps across a segment rather than
                              // switching it on, so a bar moving two
                              // positions reads as travel rather than two
                              // lights coming on at once.
                              alpha:
                                  _unlitOpacity +
                                  (1 - _unlitOpacity) *
                                      (lit - i).clamp(0.0, 1.0),
                            ),
                            borderRadius: BorderRadius.circular(height / 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );

    return Semantics(
      label: semanticLabel,
      value: '${value + 1} of $steps',
      slider: onChanged != null,
      child: bar,
    );
  }

  /// Reports the segment [position] falls in, so a drag along the row keeps
  /// handing back whichever one is under the finger.
  void _report(Offset position, BoxConstraints constraints) {
    final width = constraints.maxWidth;
    if (width <= 0) return;
    final index = (position.dx / width * steps).floor().clamp(0, steps - 1);
    if (index != value) onChanged!(index);
  }
}
