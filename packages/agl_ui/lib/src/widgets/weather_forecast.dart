import 'dart:math' as math;

import 'package:agl_ui/agl_ui.dart';

/// One day on a multi-day forecast: what the sky is doing, how likely it is
/// to rain, and where the day's temperatures sit against the rest of the
/// forecast.
///
/// Every row is given the same [scaleLow] and [scaleHigh] — the coldest and
/// warmest the whole forecast gets — so the bars line up into one picture
/// of the week instead of each day being drawn on a scale of its own.
class WeatherForecastRow extends StatelessWidget {
  const WeatherForecastRow({
    required this.dayLabel,
    required this.treatment,
    required this.low,
    required this.high,
    required this.scaleLow,
    required this.scaleHigh,
    this.precipitationProbability,
    this.marker,
    this.emphasized = false,
    super.key,
  });

  /// Which day this is, already written for display.
  final String dayLabel;

  /// The condition summarizing the day.
  final WeatherTreatment treatment;

  /// The day's low, in whole degrees.
  final int low;

  /// The day's high, in whole degrees.
  final int high;

  /// The coldest low across the whole forecast.
  final double scaleLow;

  /// The warmest high across the whole forecast.
  final double scaleHigh;

  /// The day's chance of rain as a percentage, or `null` to leave the
  /// column blank on a day with nothing worth reporting.
  final int? precipitationProbability;

  /// A temperature to mark on the bar — the reading right now, on today's
  /// row — or `null` on the days still ahead.
  final double? marker;

  /// Lifts the row's surface, marking the day the panel is really about.
  final bool emphasized;

  // The columns are shares of the row's width rather than fixed sizes.
  // Every row is given the same shares, so they still line up, and a row
  // laid out at a fraction of its final width — while the panel is growing
  // out of the card — narrows instead of overflowing.
  static const _dayFlex = 6;
  static const _precipitationFlex = 4;
  static const _temperatureFlex = 3;
  static const _barFlex = 13;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final mutedStyle = textTheme.titleSmall?.copyWith(
      color: foreground.withValues(alpha: 0.6),
    );

    final precipitationProbability = this.precipitationProbability;
    return PanelSurface(
      emphasized: emphasized,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.appSpacing.md,
          vertical: context.appSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              flex: _dayFlex,
              child: Text(
                dayLabel,
                style: textTheme.titleSmall?.copyWith(letterSpacing: 1),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppIcon(treatment.icon, size: 34),
            Expanded(
              flex: _precipitationFlex,
              child: precipitationProbability == null
                  ? const SizedBox.shrink()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AppIcon(
                          AppIcons.waterDrop,
                          size: 15,
                          color: foreground.withValues(alpha: 0.6),
                        ),
                        SizedBox(width: context.appSpacing.xxs),
                        Flexible(
                          child: Text(
                            '$precipitationProbability%',
                            style: mutedStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
            ),
            SizedBox(width: context.appSpacing.md),
            Expanded(
              flex: _temperatureFlex,
              child: Text(
                '$low°',
                style: mutedStyle,
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: context.appSpacing.sm),
            Expanded(
              flex: _barFlex,
              child: TemperatureRangeBar(
                low: low.toDouble(),
                high: high.toDouble(),
                scaleLow: scaleLow,
                scaleHigh: scaleHigh,
                marker: marker,
              ),
            ),
            SizedBox(width: context.appSpacing.sm),
            Expanded(
              flex: _temperatureFlex,
              child: Text(
                '$high°',
                style: textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The span between a day's low and high, drawn against the range the whole
/// forecast covers.
///
/// The fill is colored by where each end sits in that range rather than by
/// an absolute temperature, so the ramp reads the same whether the forecast
/// is in Celsius or Fahrenheit, and a mild week still shows its own warmest
/// day as the warm end.
class TemperatureRangeBar extends StatelessWidget {
  const TemperatureRangeBar({
    required this.low,
    required this.high,
    required this.scaleLow,
    required this.scaleHigh,
    this.marker,
    super.key,
  });

  /// The day's low.
  final double low;

  /// The day's high.
  final double high;

  /// The coldest point on the scale, drawn at the leading edge.
  final double scaleLow;

  /// The warmest point on the scale, drawn at the trailing edge.
  final double scaleHigh;

  /// A temperature to mark inside the span, or `null` for no marker.
  final double? marker;

  /// The cold end of the ramp.
  static const _cold = Color(0xFF4FC3F7);

  /// The warm end of the ramp.
  static const _warm = Color(0xFFFF9500);

  /// How thick the bar is drawn.
  static const _thickness = 10.0;

  /// Where [value] sits on the scale, clamped so a rounded reading just
  /// past either end still lands on the bar.
  double _fraction(double value) {
    final span = scaleHigh - scaleLow;
    // A forecast with no spread at all — every day the same — would divide
    // by zero, so it is drawn as one full-width bar instead.
    if (span <= 0) return value <= scaleLow ? 0 : 1;
    return ((value - scaleLow) / span).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final foreground =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    final start = _fraction(low);
    final end = _fraction(high);
    final marker = this.marker;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max<double>(constraints.maxWidth, 0);
        // Never thinner than it is tall, so a day whose high and low are
        // the same still reads as a dot on the scale rather than vanishing
        // — unless the bar itself is narrower than that, while the panel is
        // still growing out of the card.
        final minimumFill = math.min(_thickness, width);
        final fillWidth = ((end - start) * width).clamp(minimumFill, width);
        return SizedBox(
          height: _thickness,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(_thickness / 2),
                  ),
                ),
              ),
              Positioned(
                left: (start * width).clamp(0.0, width - fillWidth),
                width: fillWidth,
                top: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.lerp(_cold, _warm, start)!,
                        Color.lerp(_cold, _warm, end)!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(_thickness / 2),
                  ),
                ),
              ),
              if (marker != null)
                Positioned(
                  left: (_fraction(marker) * width - _thickness / 2).clamp(
                    0.0,
                    math.max<double>(width - _thickness, 0),
                  ),
                  width: minimumFill,
                  top: 0,
                  bottom: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: foreground,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: foreground.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// One number worth a glance beside the forecast — wind, chance of rain,
/// sunrise, sunset — named by [label] and marked with [icon].
class WeatherStatTile extends StatelessWidget {
  const WeatherStatTile({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  /// The glyph identifying what is being reported.
  final AppIconData icon;

  /// What the number is, in a word or two.
  final String label;

  /// The number itself, already formatted with its unit.
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return PanelSurface(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.appSpacing.md,
          vertical: context.appSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AppIcon(
                  icon,
                  size: 16,
                  color: foreground.withValues(alpha: 0.6),
                ),
                SizedBox(width: context.appSpacing.xxs),
                Flexible(
                  child: Text(
                    label,
                    style: textTheme.labelMedium?.copyWith(
                      color: foreground.withValues(alpha: 0.6),
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: context.appSpacing.xxs),
            Text(
              value,
              style: textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
