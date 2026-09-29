import 'dart:math' as math;

import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/cubit/drive_mode_cubit.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/models/drive_mode_advice.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/models/drive_mode_dynamics.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/models/drive_mode_settings.dart';
import 'package:agl_ivi_vgv_demo/weather/bloc/weather_tile_bloc.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

/// The Drive Mode card's overlay: the mode the car is in on the leading
/// side, the five it can be put in beside them, and the settings all five
/// come down to along the foot.
///
/// The strip along the bottom is the point of the panel. Picking a mode
/// moves all five bars at once, so the difference between Eco and Sport is
/// something the driver watches rather than something the panel asserts;
/// moving a bar by hand lands in [DriveMode.custom], seeded from whatever
/// was already in force.
///
/// Drives the same `DriveModeCubit` the card does — provided above
/// `HomeNavigator` — so a mode picked here is already on the card by the
/// time the panel closes.
class DriveModeOverlay extends StatelessWidget {
  const DriveModeOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // Its own instance rather than the weather tile's, which is provided
    // inside that card's subtree and out of reach from here. The tile's
    // request is the right one to borrow: the badge only needs to know what
    // it is doing outside right now, and paying for a five day forecast to
    // decide whether to show three words would be a poor trade.
    return BlocProvider(
      create: (context) {
        final location = context.read<AppBloc>().state.location;
        return WeatherTileBloc(
          context.read<WeatherRepository>(),
          location: location,
        )..add(WeatherTileRequested(location));
      },
      child: const _DriveModeOverlayView(),
    );
  }
}

class _DriveModeOverlayView extends StatelessWidget {
  const _DriveModeOverlayView();

  /// Clears the close button [CardOverlayScaffold] paints over the
  /// content's top-left corner.
  static const _closeButtonClearance = 80.0;

  /// The smallest the panel still reads at — set by the strip, which needs
  /// five bars side by side with a word on each. See [MinimumContentSize].
  ///
  /// The height has to stay under what a head unit actually leaves: the
  /// app's own padding, the permanent controls, the scaffold's inset and
  /// the close button clearance come off a 720 tall screen before this box
  /// is measured, and a minimum taller than the remainder would crop the
  /// strip off the bottom on every screen.
  static const _minimumContentSize = Size(900, 440);

  /// How long the panel takes to re-tint when the mode changes.
  static const _accentChange = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DriveModeCubit>().state;
    final advice = context.select<WeatherTileBloc, DriveModeAdvice?>(
      (bloc) => DriveModeAdvice.forWeather(bloc.state.weather),
    );
    final accent = context.driveModeStyleCard
        .styleFor(state.mode)
        .accentColorOr(context.appAccentTheme.color);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.appSpacing.xlg,
        _closeButtonClearance,
        context.appSpacing.xlg,
        context.appSpacing.lg,
      ),
      child: MinimumContentSize(
        size: _minimumContentSize,
        // The panel keeps one surface whichever mode is selected, so the
        // mode comes through in the accent instead. Crossfaded rather than
        // swapped, so picking one re-tints the panel rather than flicking
        // it.
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: accent),
          duration: _accentChange,
          curve: Curves.easeOutCubic,
          builder: (context, tinted, _) {
            final resolved = tinted ?? accent;
            return Column(
              children: [
                Expanded(
                  // Both columns are given the panel's height above the
                  // strip, so each lays its own content out down the side.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Proportional rather than fixed widths, so the two
                      // keep their balance at every panel size.
                      Flexible(
                        flex: 5,
                        child: _ActiveMode(state: state, accent: resolved),
                      ),
                      SizedBox(width: context.appSpacing.xlg),
                      Flexible(
                        flex: 4,
                        child: _ModeList(
                          selected: state.mode,
                          custom: state.custom,
                          advice: advice,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.appSpacing.lg),
                _ParameterStrip(
                  settings: state.settings,
                  accent: resolved,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The leading column: the mode the car is in, what it does, and what it
/// leaves in the battery.
class _ActiveMode extends StatelessWidget {
  const _ActiveMode({required this.state, required this.accent});

  /// How large the washed-in glyph is drawn before being scaled down to
  /// whatever room the column has left.
  static const _watermarkSize = 260.0;

  /// How much of the foreground the wash keeps. Matched to the weather
  /// panel's, so the two read as the same treatment.
  static const _watermarkOpacity = 0.07;

  final DriveModeState state;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final mode = state.mode;

    return Stack(
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AppIcon(
              mode.icon,
              size: _watermarkSize,
              color: foreground.withValues(alpha: _watermarkOpacity),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE MODE',
                  style: textTheme.titleSmall?.copyWith(
                    color: foreground.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: context.appSpacing.xs),
                // The name and its glyph shrink together rather than one
                // pushing the other off the column when the panel is
                // narrow.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(mode.label, style: textTheme.displayLarge),
                      SizedBox(width: context.appSpacing.sm),
                      AppIcon(mode.icon, size: 64, color: accent),
                    ],
                  ),
                ),
                SizedBox(height: context.appSpacing.xs),
                Text(
                  mode.summary,
                  style: textTheme.bodyLarge?.copyWith(
                    color: foreground.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            _RangeEstimate(
              range: state.estimatedRange,
              deltaPercent: state.rangeDeltaPercent,
              accent: accent,
            ),
          ],
        ),
      ],
    );
  }
}

/// What the battery is worth in the selected mode, and how that compares
/// with the baseline.
///
/// The one number on the panel with a cost attached to it, which is what
/// makes flicking between modes worth doing rather than a matter of taste.
class _RangeEstimate extends StatelessWidget {
  const _RangeEstimate({
    required this.range,
    required this.deltaPercent,
    required this.accent,
  });

  /// How long the figure takes to count to a new mode's.
  static const _rangeCount = Duration(milliseconds: 500);

  final int range;
  final int deltaPercent;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return PanelSurface(
      emphasized: true,
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ESTIMATED RANGE',
              style: textTheme.labelMedium?.copyWith(
                color: accent,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: context.appSpacing.xxs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                // Counted to rather than replaced, so a mode that buys
                // fifty miles is seen buying them.
                TweenAnimationBuilder<double>(
                  tween: Tween(end: range.toDouble()),
                  duration: _rangeCount,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => Text(
                    '${value.round()}',
                    style: textTheme.displayMedium,
                  ),
                ),
                SizedBox(width: context.appSpacing.xs),
                Text(
                  'mi',
                  style: textTheme.titleMedium?.copyWith(
                    color: foreground.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                Text(
                  _delta,
                  style: textTheme.titleSmall?.copyWith(color: accent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// The comparison written out, or the fact that there is nothing to
  /// compare because this mode is what the others are measured against.
  String get _delta {
    if (deltaPercent == 0) return 'BASELINE';
    final sign = deltaPercent > 0 ? '+' : '−';
    final against = DriveModeDynamics.baseline.label;
    return '$sign${deltaPercent.abs()}% vs $against';
  }
}

/// The modes the car can be put in, the selected one lifted off the panel.
class _ModeList extends StatelessWidget {
  const _ModeList({
    required this.selected,
    required this.custom,
    required this.advice,
  });

  /// How short a row is allowed to get before the list scrolls rather than
  /// squeezing further — which is what keeps the rows laid out instead of
  /// overflowing while the panel is still growing out of the card.
  ///
  /// Low enough that all five fit the shortest panel
  /// [MinimumContentSize] allows: a driver choosing a mode should not have
  /// to scroll to find out which ones there are.
  static const _minimumRowExtent = 56.0;

  final DriveMode selected;
  final DriveModeSettings custom;
  final DriveModeAdvice? advice;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing.xs;
    const modes = DriveMode.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = math.max(
          constraints.maxHeight / modes.length,
          _minimumRowExtent + spacing,
        );
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemExtent: extent,
          itemCount: modes.length,
          itemBuilder: (context, index) {
            final mode = modes[index];
            // Custom is quoted on the driver's own settings rather than on
            // the baseline it falls back to, so its row says what selecting
            // it would actually cost.
            final settings = mode == DriveMode.custom ? custom : mode.defaults;
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: _ModeRow(
                mode: mode,
                selected: mode == selected,
                deltaPercent: DriveModeState.rangeDeltaPercentOf(settings),
                recommendation: advice?.mode == mode ? advice!.reason : null,
              ),
            );
          },
        );
      },
    );
  }
}

class _ModeRow extends StatelessWidget {
  const _ModeRow({
    required this.mode,
    required this.selected,
    required this.deltaPercent,
    required this.recommendation,
  });

  final DriveMode mode;
  final bool selected;
  final int deltaPercent;

  /// Why the weather argues for this mode, or `null` when it does not.
  final String? recommendation;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    // Every row is tinted with its own mode's accent rather than the
    // selected one's, so the list carries the same colors the card does and
    // a mode can be picked out of it before its name is read.
    final accent = context.driveModeStyleCard
        .styleFor(mode)
        .accentColorOr(context.appAccentTheme.color);

    return CardTouchTarget(
      borderRadius: PanelSurface.defaultBorderRadius,
      onTap: () => context.read<DriveModeCubit>().select(mode),
      child: PanelSurface(
        emphasized: selected,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.appSpacing.md,
            vertical: context.appSpacing.xs,
          ),
          child: Row(
            children: [
              AppIcon(
                mode.icon,
                size: 32,
                color: selected ? accent : foreground.withValues(alpha: 0.7),
              ),
              SizedBox(width: context.appSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mode.label,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (recommendation != null)
                      Text(
                        recommendation!,
                        style: textTheme.labelSmall?.copyWith(
                          color: accent,
                          letterSpacing: 1.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              SizedBox(width: context.appSpacing.xs),
              Text(
                _delta,
                style: textTheme.labelLarge?.copyWith(
                  color: foreground.withValues(alpha: selected ? 0.9 : 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _delta {
    if (deltaPercent == 0) return '—';
    return '${deltaPercent > 0 ? '+' : '−'}${deltaPercent.abs()}%';
  }
}

/// The five settings every mode comes down to, adjustable.
///
/// Laid along the foot of the panel rather than inside either column, so
/// the row restating itself reads as the consequence of what was picked
/// above it.
class _ParameterStrip extends StatelessWidget {
  const _ParameterStrip({required this.settings, required this.accent});

  final DriveModeSettings settings;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return PanelSurface(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.appSpacing.md,
          vertical: context.appSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final parameter in DriveModeParameter.values) ...[
              if (parameter != DriveModeParameter.values.first)
                SizedBox(width: context.appSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            parameter.label,
                            style: textTheme.labelMedium?.copyWith(
                              color: foreground.withValues(alpha: 0.6),
                              letterSpacing: 1.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: context.appSpacing.xs),
                        Text(
                          parameter.describe(settings.valueOf(parameter)),
                          style: textTheme.labelMedium?.copyWith(
                            color: accent,
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    SteppedBar(
                      steps: DriveModeParameter.steps,
                      value: settings.valueOf(parameter),
                      color: accent,
                      semanticLabel: parameter.label,
                      onChanged: (value) =>
                          context.read<DriveModeCubit>().adjust(
                            parameter,
                            value,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
