import 'dart:math' as math;

import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ivi_vgv_demo/weather/bloc/weather_forecast_bloc.dart';
import 'package:agl_ivi_vgv_demo/weather/models/weather_condition_treatment.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:weather_repository/weather_repository.dart';

/// The Weather card's overlay: conditions right now on the leading side,
/// and the next five days listed beside them.
///
/// The days are drawn against one shared temperature scale, so the shape of
/// the week — which day is the cold one, where the warm spell falls — reads
/// off the bars without anyone having to compare the numbers.
class WeatherOverlay extends StatelessWidget {
  const WeatherOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Its own instance rather than the tile's: the overlay is pushed on
    // `HomeNavigator`, above the subtree where `WeatherTile` provides one,
    // and it asks for a different request besides.
    return BlocProvider(
      create: (context) =>
          WeatherForecastBloc(context.read<WeatherRepository>())..add(
            WeatherForecastRequested(context.read<AppBloc>().state.location),
          ),
      child: const _WeatherOverlayView(),
    );
  }
}

class _WeatherOverlayView extends StatelessWidget {
  const _WeatherOverlayView();

  /// Clears the close button [CardOverlayScaffold] paints over the
  /// content's top-left corner.
  static const _closeButtonClearance = 80.0;

  /// The smallest the two columns still read at. See [MinimumContentSize].
  static const _minimumContentSize = Size(640, 380);

  @override
  Widget build(BuildContext context) {
    // The city of reference lives in [AppBloc], so a pick in settings
    // reaches the open panel the same way it reaches the tile behind it.
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) => previous.location != current.location,
      listener: (context, state) => context.read<WeatherForecastBloc>().add(
        WeatherForecastRequested(state.location),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.appSpacing.xlg,
          _closeButtonClearance,
          context.appSpacing.xlg,
          context.appSpacing.lg,
        ),
        child: BlocBuilder<WeatherForecastBloc, WeatherForecastState>(
          builder: (context, state) {
            return switch (state) {
              WeatherForecastLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              WeatherForecastLoadFailed() => const _ForecastUnavailable(),
              WeatherForecastLoadSuccess(:final location, :final forecast) =>
                MinimumContentSize(
                  size: _minimumContentSize,
                  child: Row(
                    // Both columns are given the panel's full height, so
                    // each can lay its own content out down the whole side.
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Proportional rather than fixed widths, so the two
                      // columns keep their balance at every panel size.
                      Flexible(
                        flex: 3,
                        child: _CurrentConditions(
                          location: location,
                          forecast: forecast,
                        ),
                      ),
                      SizedBox(width: context.appSpacing.xlg),
                      Flexible(
                        flex: 5,
                        child: _FiveDayForecast(forecast: forecast),
                      ),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

/// The leading column: what it is doing outside right now, and the handful
/// of numbers worth knowing before setting off.
class _CurrentConditions extends StatelessWidget {
  const _CurrentConditions({required this.location, required this.forecast});

  final AppLocation location;
  final Forecast forecast;

  /// How large the washed-in condition is drawn before being scaled down to
  /// whatever room the column has left.
  static const _watermarkSize = 260.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final today = forecast.today;
    final treatment = forecast.current.weatherCondition.treatment;
    // Times are written the way settings asks for, the same as the
    // calendar's agenda.
    final timeFormat = context.select<AppBloc, AppTimeFormat>(
      (bloc) => bloc.state.timeFormat,
    );
    // Readings come back in metric and are converted here, so picking
    // another unit system restates the open panel rather than re-fetching
    // the forecast behind it.
    final unitSystem = context.select<AppBloc, AppUnitSystem>(
      (bloc) => bloc.state.unitSystem,
    );

    // The reading sits at the top and the numbers at the foot, the same
    // shape every card on the home screen is laid out in, with the
    // condition washed in behind the space between them — the panel's
    // answer to the dotted sun the weather card is backed with.
    return Stack(
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AppIcon(
              treatment.icon,
              size: _watermarkSize,
              color: foreground.withValues(alpha: 0.07),
            ),
          ),
        ),
        _readingAndNumbers(
          context,
          today,
          treatment,
          timeFormat,
          unitSystem,
        ),
      ],
    );
  }

  Widget _readingAndNumbers(
    BuildContext context,
    DailyForecast today,
    WeatherTreatment treatment,
    AppTimeFormat timeFormat,
    AppUnitSystem unitSystem,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.label,
              style: textTheme.titleSmall?.copyWith(
                color: foreground.withValues(alpha: 0.6),
                letterSpacing: 2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.appSpacing.xs),
            // The reading and the icon shrink together rather than one
            // pushing the other off the column when the panel is narrow.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Row(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${unitSystem.temperature(
                          forecast.current.temperature,
                        ).round()}°',
                        style: textTheme.displayLarge,
                      ),
                      SizedBox(width: context.appSpacing.xxs),
                      Text(
                        unitSystem.temperatureUnit.toAbbr,
                        style: textTheme.titleMedium?.copyWith(
                          color: foreground.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: context.appSpacing.sm),
                  AppIcon(treatment.icon, size: 64),
                ],
              ),
            ),
            Text(
              treatment.label,
              style: textTheme.titleMedium?.copyWith(
                color: context.appCardTheme.weather.accentColorOr(
                  context.appAccentTheme.color,
                ),
                letterSpacing: 1.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.appSpacing.xxs),
            Text(
              'H ${unitSystem.temperature(today.high).round()}°   '
              'L ${unitSystem.temperature(today.low).round()}°',
              style: textTheme.titleSmall?.copyWith(
                color: foreground.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        _TodayStats(
          today: today,
          timeFormat: timeFormat,
          unitSystem: unitSystem,
        ),
      ],
    );
  }
}

/// Today's numbers, in a block of four so the column below the temperature
/// reads as one deliberate shape rather than a list trailing off.
class _TodayStats extends StatelessWidget {
  const _TodayStats({
    required this.today,
    required this.timeFormat,
    required this.unitSystem,
  });

  final DailyForecast today;
  final AppTimeFormat timeFormat;
  final AppUnitSystem unitSystem;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing.xs;
    final tiles = [
      WeatherStatTile(
        icon: AppIcons.wind,
        label: 'WIND',
        value: unitSystem.formatWindSpeed(today.windSpeed),
      ),
      WeatherStatTile(
        icon: AppIcons.waterDrop,
        label: 'RAIN',
        value: '${today.precipitationProbability}%',
      ),
      WeatherStatTile(
        icon: AppIcons.sunrise,
        label: 'SUNRISE',
        value: timeFormat.format(today.sunrise),
      ),
      WeatherStatTile(
        icon: AppIcons.sunset,
        label: 'SUNSET',
        value: timeFormat.format(today.sunset),
      ),
    ];

    return Column(
      children: [
        for (var row = 0; row < tiles.length; row += 2) ...[
          if (row > 0) SizedBox(height: spacing),
          // Both tiles in a pair are given the height of the taller one,
          // which the scrolling column above cannot supply on its own.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: tiles[row]),
                SizedBox(width: spacing),
                Expanded(child: tiles[row + 1]),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// The days ahead, today first.
class _FiveDayForecast extends StatelessWidget {
  const _FiveDayForecast({required this.forecast});

  final Forecast forecast;

  /// How short a row is allowed to get before the list scrolls instead of
  /// squeezing further — which is what keeps the rows laid out rather than
  /// overflowing while the panel is still growing out of the card.
  static const _minimumRowExtent = 56.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final days = forecast.days;
    final spacing = context.appSpacing.xs;
    // Every temperature on the rows — the ends of each bar and the scale
    // they are drawn against — goes through the same conversion, so the
    // shape of the week is unchanged by which system is picked.
    final unitSystem = context.select<AppBloc, AppUnitSystem>(
      (bloc) => bloc.state.unitSystem,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${days.length}-DAY FORECAST',
          style: textTheme.labelMedium?.copyWith(
            color: context.appCardTheme.weather.accentColorOr(
              context.appAccentTheme.color,
            ),
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: context.appSpacing.sm),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final extent = math.max(
                constraints.maxHeight / days.length,
                _minimumRowExtent + spacing,
              );
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemExtent: extent,
                itemCount: days.length,
                itemBuilder: (context, index) {
                  final day = days[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: spacing),
                    child: WeatherForecastRow(
                      dayLabel: _dayLabel(index, day),
                      treatment: day.condition.treatment,
                      low: unitSystem.temperature(day.low).round(),
                      high: unitSystem.temperature(day.high).round(),
                      scaleLow: unitSystem.temperature(forecast.low),
                      scaleHigh: unitSystem.temperature(forecast.high),
                      // A day nothing is expected to fall on says nothing,
                      // rather than repeating "0%" down the column.
                      precipitationProbability: day.precipitationProbability > 0
                          ? day.precipitationProbability
                          : null,
                      // Only today knows where it currently sits in its own
                      // range.
                      marker: index == 0
                          ? unitSystem.temperature(
                              forecast.current.temperature,
                            )
                          : null,
                      emphasized: index == 0,
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  /// Names the row: the first one is today wherever the city is, and the
  /// rest are weekdays.
  String _dayLabel(int index, DailyForecast day) =>
      index == 0 ? 'TODAY' : DateFormat('EEEE').format(day.date).toUpperCase();
}

/// Shown when the forecast could not be fetched — offline, or the service
/// is down — in place of a panel of empty rows.
class _ForecastUnavailable extends StatelessWidget {
  const _ForecastUnavailable();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(
            AppIcons.weatherCloudy,
            size: 64,
            color: foreground.withValues(alpha: 0.4),
          ),
          SizedBox(height: context.appSpacing.md),
          Text(
            'FORECAST UNAVAILABLE',
            style: textTheme.titleMedium?.copyWith(
              color: foreground.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
