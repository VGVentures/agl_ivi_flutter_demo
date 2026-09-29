import 'dart:math' as math;

import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ivi_vgv_demo/powertrain/models/powertrain_telemetry.dart';
import 'package:agl_ivi_vgv_demo/powertrain/models/trip.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The panel behind the home screen's Efficiency / EV Range / Boost stack.
///
/// One panel rather than three, because the three cards share one slot on
/// the grid and one tap: splitting the target by whichever card the stack
/// happened to be scrolled to would make what opens a matter of luck. They
/// are also one question asked three ways — what the battery is worth,
/// where it went, and what the powertrain is doing to spend it — so the
/// answers are worth more side by side than apart.
///
/// Range is quoted off [DriveModeCubit] rather than held here, so the
/// figure on this panel is the same one the Drive Mode panel moves: a
/// driver who picks Sport there and opens this cannot be told two
/// different things about the same battery.
class PowertrainOverlay extends StatelessWidget {
  const PowertrainOverlay({
    this.telemetry = PowertrainTelemetry.demo,
    super.key,
  });

  /// What the battery and the powertrain are reporting.
  final PowertrainTelemetry telemetry;

  /// Clears the close button [CardOverlayScaffold] paints over the
  /// content's top-left corner.
  static const _closeButtonClearance = 80.0;

  /// The smallest the three sections still read at. See
  /// [MinimumContentSize].
  ///
  /// Set by the efficiency chart, which needs five bars side by side with
  /// three lines of figures on each, and kept under what a 720 tall head
  /// unit leaves once the app's padding, the permanent controls, the
  /// scaffold's inset and the close button clearance come off it.
  static const _minimumContentSize = Size(900, 440);

  @override
  Widget build(BuildContext context) {
    final accent = context.tripEfficiencyCardStyle.accentColorOr(
      context.appAccentTheme.color,
    );
    final driveMode = context.watch<DriveModeCubit>().state;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.appSpacing.xlg,
        _closeButtonClearance,
        context.appSpacing.xlg,
        context.appSpacing.lg,
      ),
      child: MinimumContentSize(
        size: _minimumContentSize,
        child: Row(
          // Both columns are given the panel's full height, so each lays
          // its own content out down the whole side.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Proportional rather than fixed widths, so the two columns
            // keep their balance at every panel size.
            Flexible(
              flex: 4,
              child: _RangeSection(
                telemetry: telemetry,
                driveMode: driveMode,
                accent: accent,
              ),
            ),
            SizedBox(width: context.appSpacing.xlg),
            Flexible(
              flex: 5,
              child: Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: _EfficiencySection(
                      telemetry: telemetry,
                      accent: accent,
                    ),
                  ),
                  SizedBox(height: context.appSpacing.md),
                  Expanded(
                    flex: 2,
                    child: _BoostSection(
                      telemetry: telemetry,
                      accent: accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The leading section: what the battery is worth, and what the car is
/// spending it at.
///
/// Given the whole leading column rather than a third of the panel because
/// it is the one figure a driver opens this for; the other two sections
/// explain it.
class _RangeSection extends StatelessWidget {
  const _RangeSection({
    required this.telemetry,
    required this.driveMode,
    required this.accent,
  });

  final PowertrainTelemetry telemetry;
  final DriveModeState driveMode;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionLabel('EV RANGE', accent: accent),
        SizedBox(height: context.appSpacing.sm),
        Expanded(
          child: _ChargeGauge(
            percent: telemetry.batteryPercent,
            range: driveMode.estimatedRange,
            accent: accent,
          ),
        ),
        SizedBox(height: context.appSpacing.md),
        PanelSurface(
          emphasized: true,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.appSpacing.md,
              vertical: context.appSpacing.sm,
            ),
            child: Row(
              children: [
                _Stat(label: 'CHARGE', value: '${telemetry.batteryPercent}%'),
                _Stat(
                  label: 'IN PACK',
                  value:
                      '${telemetry.energyRemainingKwh.toStringAsFixed(1)} kWh',
                ),
                _Stat(
                  label: 'IN ${driveMode.mode.label.toUpperCase()}',
                  value: _modeDelta,
                  valueColor: accent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// What the mode in force is doing to the range, or the fact that it is
  /// the mode every other one is measured against.
  String get _modeDelta {
    final delta = driveMode.rangeDeltaPercent;
    if (delta == 0) return 'BASELINE';
    return '${delta > 0 ? '+' : '−'}${delta.abs()}%';
  }
}

/// The battery drawn as an arc, with the miles it is worth in the middle.
///
/// An arc rather than a bar: the panel's hero figure needs somewhere to
/// sit, and the charge reads off the sweep without the number in the
/// center having to compete with it.
class _ChargeGauge extends StatelessWidget {
  const _ChargeGauge({
    required this.percent,
    required this.range,
    required this.accent,
  });

  final int percent;
  final int range;
  final Color accent;

  /// Where the arc begins, in degrees clockwise from three o'clock, and
  /// how far it runs. The gap it leaves sits at the bottom, under the
  /// readout.
  static const _startAngle = 150.0;
  static const _sweepAngle = 240.0;

  /// How thick the arc is drawn, as a fraction of the gauge's side, so it
  /// keeps its weight at every panel size.
  static const _strokeFactor = 0.075;

  /// How long the arc takes to fill, and the figure to count, when the
  /// panel opens.
  static const _fill = Duration(milliseconds: 700);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Square, so the arc is a circle rather than an ellipse, and
        // centered in whatever the column has left.
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox.square(
            dimension: side,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: percent / 100),
              duration: _fill,
              curve: Curves.easeOutCubic,
              builder: (context, progress, child) => CustomPaint(
                painter: _ChargeArcPainter(
                  progress: progress,
                  color: accent,
                  trackColor: foreground.withValues(alpha: 0.15),
                  strokeWidth: side * _strokeFactor,
                  startAngle: _startAngle,
                  sweepAngle: _sweepAngle,
                ),
                child: child,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Counted to rather than replaced, so a mode that
                    // buys thirty miles is seen buying them.
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: range.toDouble()),
                      duration: _fill,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) => Text(
                        '${value.round()}',
                        style: textTheme.displayLarge,
                      ),
                    ),
                    Text(
                      'MILES',
                      style: textTheme.labelMedium?.copyWith(
                        color: foreground.withValues(alpha: 0.6),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChargeArcPainter extends CustomPainter {
  const _ChargeArcPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
    required this.startAngle,
    required this.sweepAngle,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final double startAngle;
  final double sweepAngle;

  static double _radians(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    // Inset by half the stroke, which straddles the path: an arc drawn on
    // the box's own edge would have its outer half clipped away.
    final bounds = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    if (bounds.isEmpty) return;

    final start = _radians(startAngle);
    final sweep = _radians(sweepAngle);

    Paint stroke(Color color) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawArc(bounds, start, sweep, false, stroke(trackColor));
    if (progress > 0) {
      canvas.drawArc(
        bounds,
        start,
        sweep * progress.clamp(0.0, 1.0),
        false,
        stroke(color),
      );
    }
  }

  @override
  bool shouldRepaint(_ChargeArcPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        color != oldDelegate.color ||
        trackColor != oldDelegate.trackColor ||
        strokeWidth != oldDelegate.strokeWidth ||
        startAngle != oldDelegate.startAngle ||
        sweepAngle != oldDelegate.sweepAngle;
  }
}

/// Where the battery has been going: one bar per trip, as tall as the
/// charge it spent, tinted by whether it was worth it.
///
/// The card this grew out of plots the same five bars and stops there,
/// which says which trip was longest and nothing about how it was driven.
/// Pairing each bar with the miles it bought per kilowatt hour — and
/// picking out the trips that beat the average — turns the chart from a
/// log into a verdict.
class _EfficiencySection extends StatelessWidget {
  const _EfficiencySection({required this.telemetry, required this.accent});

  final PowertrainTelemetry telemetry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final average = telemetry.averageMilesPerKwh;

    return PanelSurface(
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _SectionLabel('EFFICIENCY', accent: accent),
                const Spacer(),
                Text(
                  '${average.toStringAsFixed(1)} mi/kWh average',
                  style: textTheme.labelLarge?.copyWith(
                    color: foreground.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            SizedBox(height: context.appSpacing.sm),
            Expanded(
              child: _TripChart(
                telemetry: telemetry,
                average: average,
                accent: accent,
              ),
            ),
            SizedBox(height: context.appSpacing.sm),
            Row(
              children: [
                _Stat(
                  label: 'BEST',
                  value:
                      '${telemetry.bestMilesPerKwh.toStringAsFixed(1)} mi/kWh',
                ),
                _Stat(label: 'DISTANCE', value: '${telemetry.totalMiles} mi'),
                _Stat(
                  label: 'ENERGY',
                  value: '${telemetry.totalEnergyKwh.round()} kWh',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripChart extends StatelessWidget {
  const _TripChart({
    required this.telemetry,
    required this.average,
    required this.accent,
  });

  final PowertrainTelemetry telemetry;
  final double average;
  final Color accent;

  static const _barBorderRadius = 8.0;

  /// How long the bars take to grow when the panel opens.
  static const _grow = Duration(milliseconds: 600);

  @override
  Widget build(BuildContext context) {
    final trips = telemetry.trips;
    if (trips.isEmpty) return const SizedBox.shrink();

    // The thirstiest trip fills the chart and the rest are measured
    // against it, the same way the card plots them.
    final tallest = trips
        .map((trip) => trip.batteryPercent)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final trip in trips)
          Expanded(
            child: _TripBar(
              trip: trip,
              packKwh: telemetry.packKwh,
              heightFactor: tallest == 0 ? 0 : trip.batteryPercent / tallest,
              // Tinting the bars that beat the average puts the verdict
              // in the shape of the chart, so it reads before any of the
              // five rates underneath it does.
              beatsAverage: trip.milesPerKwh(telemetry.packKwh) >= average,
              accent: accent,
              grow: _grow,
              borderRadius: _barBorderRadius,
            ),
          ),
      ],
    );
  }
}

class _TripBar extends StatelessWidget {
  const _TripBar({
    required this.trip,
    required this.packKwh,
    required this.heightFactor,
    required this.beatsAverage,
    required this.accent,
    required this.grow,
    required this.borderRadius,
  });

  final Trip trip;
  final double packKwh;
  final double heightFactor;
  final bool beatsAverage;
  final Color accent;
  final Duration grow;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final rate = trip.milesPerKwh(packKwh);
    final color = beatsAverage ? accent : foreground.withValues(alpha: 0.3);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.appSpacing.xxs),
      // Stretching gives the bar a tight width to fill; a childless
      // DecoratedBox would otherwise collapse to nothing.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FitText('${trip.batteryPercent}%', style: textTheme.labelLarge),
          SizedBox(height: context.appSpacing.xxs),
          Expanded(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: heightFactor),
              duration: grow,
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: value.clamp(0.0, 1.0),
                widthFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: context.appSpacing.xs),
          _FitText(
            trip.label,
            style: textTheme.labelMedium?.copyWith(
              color: foreground.withValues(alpha: 0.6),
            ),
          ),
          _FitText(
            rate.toStringAsFixed(1),
            style: textTheme.labelSmall?.copyWith(color: color),
          ),
          _FitText(
            '${trip.miles} mi',
            style: textTheme.labelSmall?.copyWith(
              color: foreground.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// What the powertrain is doing right now.
///
/// The one live reading on the panel: charge and trip history are what has
/// already happened, and this is the throttle being asked for. Drawn
/// against the whole band the compressor works in — vacuum through
/// wastegate — so a figure in psi means something without the driver
/// having to know what a high one is.
class _BoostSection extends StatelessWidget {
  const _BoostSection({required this.telemetry, required this.accent});

  final PowertrainTelemetry telemetry;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return PanelSurface(
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                _SectionLabel('BOOST', accent: accent),
                const Spacer(),
                Text(
                  telemetry.boostPsi.toStringAsFixed(2),
                  style: textTheme.headlineLarge,
                ),
                SizedBox(width: context.appSpacing.xs),
                Text(
                  'psi',
                  style: textTheme.titleSmall?.copyWith(
                    color: foreground.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            _BoostGauge(
              psi: telemetry.boostPsi,
              peakPsi: telemetry.boostPeakPsi,
              accent: accent,
            ),
            Row(
              children: [
                _Stat(
                  label: 'PEAK',
                  value: '${telemetry.boostPeakPsi.toStringAsFixed(1)} psi',
                  valueColor: accent,
                ),
                _Stat(
                  label: 'WASTEGATE',
                  value:
                      '${PowertrainTelemetry.maxBoostPsi.toStringAsFixed(1)} '
                      'psi',
                ),
                _Stat(label: 'STATE', value: _state),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Which end of the band the reading is at, written out.
  ///
  /// A number in psi only means something to a driver who already knows
  /// what a high one is; naming the state is what the gauge is for.
  String get _state {
    const margin = 0.5;
    final psi = telemetry.boostPsi;
    if (psi < -margin) return 'VACUUM';
    if (psi <= margin) return 'ATMOSPHERIC';
    if (psi >= PowertrainTelemetry.maxBoostPsi - margin) return 'WASTEGATE';
    return 'ON BOOST';
  }
}

/// The boost band drawn end to end, filled from atmospheric to wherever
/// the needle is.
///
/// Filling out of zero rather than out of the left edge is the whole
/// point: off the throttle the bar empties towards vacuum, on it the bar
/// grows towards the wastegate, and which side of atmospheric the engine
/// is on reads without a number.
class _BoostGauge extends StatelessWidget {
  const _BoostGauge({
    required this.psi,
    required this.peakPsi,
    required this.accent,
  });

  final double psi;
  final double peakPsi;
  final Color accent;

  /// How thick the band is, and how far the ticks that mark atmospheric
  /// and the peak stand out of it on each side.
  static const _bandHeight = 18.0;
  static const _tickOverhang = 5.0;

  /// How long the fill takes to reach the reading when the panel opens.
  static const _fill = Duration(milliseconds: 600);

  static const double _trackHeight = _bandHeight + _tickOverhang * 2;

  /// Where [psi] falls along the band, from 0 at full vacuum to 1 at the
  /// wastegate.
  static double _fraction(double psi) {
    const span =
        PowertrainTelemetry.maxBoostPsi - PowertrainTelemetry.vacuumPsi;
    return ((psi - PowertrainTelemetry.vacuumPsi) / span).clamp(0.0, 1.0);
  }

  /// [fraction] as an [Alignment]'s horizontal coordinate, which runs from
  /// −1 to 1 instead.
  static double _alignX(double fraction) => fraction * 2 - 1;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final zero = _fraction(0);
    final reading = _fraction(psi);
    final peak = _fraction(peakPsi);

    final scaleLabel = textTheme.labelSmall?.copyWith(
      color: foreground.withValues(alpha: 0.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _trackHeight,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: _tickOverhang,
                    height: _bandHeight,
                    child: _Band(color: foreground.withValues(alpha: 0.15)),
                  ),
                  // Grown rather than drawn in place, so the panel opens
                  // onto the needle arriving at the reading.
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: reading),
                    duration: _fill,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      final from = math.min(zero, value) * width;
                      final to = math.max(zero, value) * width;
                      return Positioned(
                        left: from,
                        width: to - from,
                        top: _tickOverhang,
                        height: _bandHeight,
                        child: _Band(color: accent),
                      );
                    },
                  ),
                  _Tick(
                    fraction: zero,
                    color: foreground.withValues(alpha: 0.7),
                    width: 2,
                  ),
                  _Tick(fraction: peak, color: accent, width: 3),
                ],
              );
            },
          ),
        ),
        SizedBox(height: context.appSpacing.xxs),
        // Aligned proportionally rather than positioned, so a label near
        // an end slides inside the band instead of running off it.
        SizedBox(
          height: (scaleLabel?.fontSize ?? 11) * 1.5,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${PowertrainTelemetry.vacuumPsi.toStringAsFixed(0)} VAC',
                  style: scaleLabel,
                ),
              ),
              Align(
                alignment: Alignment(_alignX(zero), 0),
                child: Text('0', style: scaleLabel),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '+${PowertrainTelemetry.maxBoostPsi.toStringAsFixed(1)}',
                  style: scaleLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Band extends StatelessWidget {
  const _Band({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_BoostGauge._bandHeight / 2),
      ),
    );
  }
}

/// A mark across the boost band at [fraction] of its width.
class _Tick extends StatelessWidget {
  const _Tick({
    required this.fraction,
    required this.color,
    required this.width,
  });

  final double fraction;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(_BoostGauge._alignX(fraction), 0),
      child: SizedBox(
        width: width,
        height: _BoostGauge._trackHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(width / 2),
          ),
        ),
      ),
    );
  }
}

/// A section's name, picked out in the panel's accent so the three read as
/// headings rather than as more of the figures under them.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {required this.accent});

  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(color: accent, letterSpacing: 2),
    );
  }
}

/// One labelled figure in a row of them along the foot of a section.
class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;

  /// Picks the figure out of the row when it is the one that changes.
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _FitText(
            label,
            alignment: AlignmentDirectional.centerStart,
            style: textTheme.labelSmall?.copyWith(
              color: foreground.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
          _FitText(
            value,
            alignment: AlignmentDirectional.centerStart,
            style: textTheme.labelLarge?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

/// A single line that shrinks to fit rather than ellipsizing, since a
/// chart column is a fifth of a section wide and a stat is a third.
class _FitText extends StatelessWidget {
  const _FitText(
    this.text, {
    required this.style,
    this.alignment = Alignment.center,
  });

  final String text;
  final TextStyle? style;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(text, style: style, maxLines: 1, softWrap: false),
    );
  }
}
