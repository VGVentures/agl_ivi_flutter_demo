import 'package:agl_ivi_vgv_demo/hvac/cubit/cabin_climate_cubit.dart';
import 'package:agl_ivi_vgv_demo/hvac/models/cabin_climate.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _coldColor = Color(0xFF2F80FF);
const _hotColor = Color(0xFFFF3B30);

double _temperatureFraction(double value) =>
    ((value - CabinClimate.minTemperature) /
            (CabinClimate.maxTemperature - CabinClimate.minTemperature))
        .clamp(0, 1)
        .toDouble();

Color _temperatureColor(double value) =>
    Color.lerp(_coldColor, _hotColor, _temperatureFraction(value))!;

/// One side of the permanent climate controls along the foot of the
/// screen: target temperature, fan, seat recline, air conditioning and seat
/// heat.
///
/// Reads and writes the one [CabinClimateCubit] both panels share, picking
/// out its own [CabinSide], so a driver profile applied from an overlay
/// lands on these controls without the panel having to be told.
class HvacPanel extends StatefulWidget {
  const HvacPanel({super.key, this.isOnDriverSide = true});

  final bool isOnDriverSide;

  @override
  State<HvacPanel> createState() => _HvacPanelState();
}

class _HvacPanelState extends State<HvacPanel> {
  final _temperatureLink = LayerLink();
  OverlayEntry? _overlayEntry;

  /// The side of the cabin these controls move.
  CabinSide get _side =>
      widget.isOnDriverSide ? CabinSide.driver : CabinSide.passenger;

  @override
  void dispose() {
    _removeTemperatureSlider();
    super.dispose();
  }

  void _toggleTemperatureSlider() {
    if (_overlayEntry != null) {
      _removeTemperatureSlider();
    } else {
      _showTemperatureSlider();
    }
  }

  void _removeTemperatureSlider() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showTemperatureSlider() {
    // Read here rather than in the overlay's builder: the entry is inserted
    // into the app's overlay, above this panel, where a lookup by type
    // would not find the cubit — and could not tell the two sides apart if
    // it did.
    final cubit = context.read<CabinClimateCubit>();
    final side = _side;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeTemperatureSlider,
              ),
            ),
            CompositedTransformFollower(
              link: _temperatureLink,
              targetAnchor: Alignment.topCenter,
              followerAnchor: Alignment.bottomCenter,
              offset: Offset(0, -context.appSpacing.sm),
              child: Material(
                color: Colors.transparent,
                child: BlocBuilder<CabinClimateCubit, CabinClimateState>(
                  bloc: cubit,
                  builder: (context, state) {
                    return _TemperatureSlider(
                      value: state.of(side).temperature,
                      onChanged: (temperature) =>
                          cubit.setTemperature(side, temperature),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    // Only this side is watched, so moving the passenger's fan leaves the
    // driver's controls alone.
    final climate = context.select<CabinClimateCubit, CabinClimate>(
      (cubit) => cubit.state.of(_side),
    );
    final cubit = context.read<CabinClimateCubit>();
    return Row(
      spacing: context.appSpacing.md,
      children: [
        CompositedTransformTarget(
          link: _temperatureLink,
          child: GestureDetector(
            onTap: _toggleTemperatureSlider,
            child: IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: context.appSpacing.xxs,
                children: [
                  Container(
                    height: _LevelIndicator._lightSize,
                    decoration: BoxDecoration(
                      color: _temperatureColor(climate.temperature),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Text(
                    '${climate.temperature.round()}°',
                    textAlign: TextAlign.center,
                    style: ts.displayMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
        _ControlColumn(
          icon: AppIcons.iconFan,
          activeLights: climate.fanSpeed,
          onPressed: () => cubit.cycleFanSpeed(_side),
        ),
        _ControlColumn(
          icon: AppIcons.seatRecline,
          activeLights: climate.seatRecline,
          onPressed: () => cubit.cycleSeatRecline(_side),
        ),
        _ControlColumn(
          icon: AppIcons.acSnowflake24,
          activeLights: climate.isAcOn ? 1 : 0,
          maxLevel: 1,
          onPressed: () => cubit.toggleAc(_side),
        ),
        _ControlColumn(
          icon: AppIcons.seatHeat,
          activeLights: climate.seatHeat,
          onPressed: () => cubit.cycleSeatHeat(_side),
        ),
      ].reverseIf(condition: widget.isOnDriverSide),
    );
  }
}

/// One control on the panel: its lights above the button that cycles them.
class _ControlColumn extends StatelessWidget {
  const _ControlColumn({
    required this.icon,
    required this.activeLights,
    required this.onPressed,
    this.maxLevel = CabinClimate.maxLevel,
  });

  final AppIconData icon;
  final int activeLights;
  final VoidCallback onPressed;
  final int maxLevel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: context.appSpacing.xxs,
      children: [
        _LevelIndicator(activeLights: activeLights, maxLevel: maxLevel),
        IconButton(
          onPressed: onPressed,
          icon: AppIcon(icon, size: AppIconSizes.control),
        ),
      ],
    );
  }
}

/// A row of [maxLevel] small lights above an HVAC toggle icon, lighting up
/// from left to right as [activeLights] increases.
class _LevelIndicator extends StatelessWidget {
  const _LevelIndicator({
    required this.activeLights,
    this.maxLevel = CabinClimate.maxLevel,
  });

  final int activeLights;
  final int maxLevel;

  static const _lightSize = 10.0;

  @override
  Widget build(BuildContext context) {
    final litColor = context.appAccentTheme.color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: context.appSpacing.xxs,
      children: List.generate(maxLevel, (index) {
        final isLit = index < activeLights;
        return Container(
          width: _lightSize,
          height: _lightSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isLit ? litColor : Colors.transparent,
            border: Border.all(
              color: isLit ? litColor : Colors.grey.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
        );
      }),
    );
  }
}

/// A vertical slider that lets the driver drag between
/// [CabinClimate.minTemperature] and [CabinClimate.maxTemperature], painting a
/// gradient track from cold ([_coldColor]) to hot ([_hotColor]) so the
/// thumb's position always matches its color.
class _TemperatureSlider extends StatelessWidget {
  const _TemperatureSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  static const _trackWidth = 64.0;
  static const _trackHeight = 260.0;
  static const _thumbSize = 56.0;
  static const _thumbInset = 16.0;

  double get _fraction => _temperatureFraction(value);

  void _updateFromLocalDy(double dy) {
    const travelHeight = _trackHeight - 2 * _thumbInset;
    final fractionFromTop = ((dy - _thumbInset) / travelHeight).clamp(
      0.0,
      1.0,
    );
    final newValue =
        CabinClimate.maxTemperature -
        fractionFromTop *
            (CabinClimate.maxTemperature - CabinClimate.minTemperature);
    onChanged(newValue.roundToDouble());
  }

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    final thumbColor = _temperatureColor(value);
    return GestureDetector(
      onTapDown: (details) => _updateFromLocalDy(details.localPosition.dy),
      onVerticalDragUpdate: (details) =>
          _updateFromLocalDy(details.localPosition.dy),
      child: Container(
        width: _trackWidth,
        height: _trackHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_trackWidth / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_trackWidth / 2),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [_coldColor, _hotColor],
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 100),
                  top:
                      _thumbInset +
                      (_trackHeight - _thumbSize - 2 * _thumbInset) *
                          (1 - _fraction),
                  left: (_trackWidth - _thumbSize) / 2,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: thumbColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      '${value.round()}°',
                      style: ts.titleMedium?.copyWith(
                        color: thumbColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on List<Widget> {
  List<Widget> reverseIf({required bool condition}) =>
      condition ? this : reversed.toList();
}
