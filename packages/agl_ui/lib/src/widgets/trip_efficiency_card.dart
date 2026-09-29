import 'dart:ui';

import 'package:agl_ui/agl_ui.dart';

/// The treatment of the card stack the home screen puts Efficiency, EV
/// Range and Boost in, and of the panel all three open onto.
///
/// The three cards share one slot on the grid and one overlay, so the
/// panel's surface and label color are named once here rather than per
/// card.
class TripEfficiencyCardStyle extends ThemeExtension<TripEfficiencyCardStyle> {
  const TripEfficiencyCardStyle({
    required this.backgroundColor,
    required this.barColor,
    required this.borderRadius,
    this.overlayBackgroundColor,
    this.accentColor,
  });

  final Color backgroundColor;
  final Color barColor;
  final double borderRadius;

  /// Painted behind the panel the stack opens, in place of
  /// [backgroundColor].
  ///
  /// The card is a small block among several, and its color is chosen at
  /// that size; a whole panel of it leaves three sections' worth of dense
  /// readouts nothing to sit on. Leave `null` when the card's own color
  /// works at panel scale, and read it through [overlaySurfaceColor]
  /// rather than directly.
  final Color? overlayBackgroundColor;

  /// The color the panel picks its section labels out in.
  ///
  /// Leave `null` to fall back to the app's own accent; resolve it with
  /// [accentColorOr].
  final Color? accentColor;

  /// The color the panel opened from this card settles on.
  Color get overlaySurfaceColor => overlayBackgroundColor ?? backgroundColor;

  /// This card's own [accentColor], or [fallback] when it names none.
  Color accentColorOr(Color fallback) => accentColor ?? fallback;

  @override
  TripEfficiencyCardStyle copyWith({
    Color? backgroundColor,
    Color? barColor,
    double? borderRadius,
    Color? overlayBackgroundColor,
    Color? accentColor,
  }) {
    return TripEfficiencyCardStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      barColor: barColor ?? this.barColor,
      borderRadius: borderRadius ?? this.borderRadius,
      overlayBackgroundColor:
          overlayBackgroundColor ?? this.overlayBackgroundColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  @override
  TripEfficiencyCardStyle lerp(
    covariant ThemeExtension<TripEfficiencyCardStyle>? other,
    double t,
  ) {
    if (other is! TripEfficiencyCardStyle) {
      return this;
    }
    return TripEfficiencyCardStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      barColor: Color.lerp(barColor, other.barColor, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      // Interpolating the resolved surfaces rather than the raw fields
      // keeps a style that falls back to [backgroundColor] lerping against
      // one that names its own, instead of fading in from nothing. Both
      // sides unset stays unset, so the endpoints compare equal to their
      // originals.
      overlayBackgroundColor:
          overlayBackgroundColor == null && other.overlayBackgroundColor == null
          ? null
          : Color.lerp(overlaySurfaceColor, other.overlaySurfaceColor, t),
      accentColor: Color.lerp(accentColor, other.accentColor, t),
    );
  }
}

/// The number of trips the chart plots, counting back from the latest one.
const _maxBars = 5;
const _barBorderRadius = 8.0;

class TripEfficiencyCard extends StatelessWidget {
  const TripEfficiencyCard({
    required this.title,
    required this.batteryConsumption,
    super.key,
  });

  final String title;

  /// The battery consumption of each trip, as `(label, percentage)` pairs
  /// ordered from oldest to most recent.
  final List<(String, int)> batteryConsumption;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    final style = context.tripEfficiencyCardStyle;
    return Card(
      color: style.backgroundColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: ts.titleMedium,
            ),
            SizedBox(height: context.appSpacing.md),
            Expanded(
              child: _BatteryConsumptionChart(
                batteryConsumption: batteryConsumption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatteryConsumptionChart extends StatelessWidget {
  const _BatteryConsumptionChart({required this.batteryConsumption});

  final List<(String, int)> batteryConsumption;

  @override
  Widget build(BuildContext context) {
    if (batteryConsumption.isEmpty) {
      return const SizedBox.shrink();
    }
    final trips = batteryConsumption.length > _maxBars
        ? batteryConsumption.sublist(batteryConsumption.length - _maxBars)
        : batteryConsumption;
    final highestConsumption = trips
        .map((trip) => trip.$2)
        .reduce((a, b) => a > b ? a : b);
    return Row(
      children: [
        for (final (label, consumption) in trips)
          Expanded(
            child: _Bar(
              label: label,
              consumption: consumption,
              // The thirstiest trip fills the chart and the rest are
              // measured against it.
              heightFactor: highestConsumption == 0
                  ? 0
                  : consumption / highestConsumption,
            ),
          ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.consumption,
    required this.heightFactor,
  });

  final String label;
  final int consumption;
  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    final style = context.tripEfficiencyCardStyle;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.appSpacing.xxs),
      // Stretching gives the bar a tight width to fill; a childless
      // DecoratedBox would otherwise collapse to nothing.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BarText('$consumption%', style: ts.labelLarge),
          SizedBox(height: context.appSpacing.xxs),
          Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.bottomCenter,
              heightFactor: heightFactor,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: style.barColor,
                  borderRadius: BorderRadius.circular(_barBorderRadius),
                ),
              ),
            ),
          ),
          SizedBox(height: context.appSpacing.xs),
          _BarText(label, style: ts.labelMedium),
        ],
      ),
    );
  }
}

/// A single line of text that shrinks to fit its bar instead of ellipsizing,
/// since a bar is only a fifth of the card wide.
class _BarText extends StatelessWidget {
  const _BarText(this.text, {required this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, style: style, maxLines: 1, softWrap: false),
    );
  }
}
