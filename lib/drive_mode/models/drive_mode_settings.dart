import 'package:equatable/equatable.dart';

/// One of the five things a drive mode sets.
///
/// Five rather than the dozen a real chassis exposes: these are the ones a
/// driver can feel from the seat, and the panel draws them side by side, so
/// a sixth would cost more than it explains.
enum DriveModeParameter {
  throttle(
    label: 'THROTTLE',
    scale: ['GENTLE', 'EASY', 'LINEAR', 'EAGER', 'SHARP'],
  ),
  regen(
    label: 'REGEN',
    scale: ['COAST', 'LIGHT', 'MODERATE', 'STRONG', 'MAX'],
  ),
  steering(
    label: 'STEERING',
    scale: ['LIGHT', 'RELAXED', 'NEUTRAL', 'FIRM', 'WEIGHTED'],
  ),
  suspension(
    label: 'SUSPENSION',
    scale: ['PLUSH', 'SOFT', 'NEUTRAL', 'TAUT', 'FIRM'],
  ),
  climate(
    label: 'CLIMATE',
    scale: ['FRUGAL', 'SAVING', 'BALANCED', 'GENEROUS', 'FULL'],
  );

  const DriveModeParameter({required this.label, required this.scale});

  /// How many positions every parameter has.
  ///
  /// One number rather than one per parameter, so the five bars on the
  /// panel are read against the same ruler and a mode's shape can be taken
  /// in at a glance.
  static const int steps = 5;

  /// The middle position, which the baseline mode sits at throughout and
  /// which the range estimate is measured from.
  static const int middle = steps ~/ 2;

  /// What the parameter is called on the panel.
  final String label;

  /// What each position is called, softest first. One word per position in
  /// [steps].
  final List<String> scale;

  /// The word for [value], for the line under the bar.
  String describe(int value) => scale[value.clamp(0, steps - 1)];
}

/// {@template drive_mode_settings}
/// Where a drive mode leaves each of the five parameters.
///
/// Every field is a position from 0 to `DriveModeParameter.steps - 1`
/// rather than a physical quantity: the panel draws positions, and a demo
/// has no chassis to hand real damper rates to.
/// {@endtemplate}
class DriveModeSettings extends Equatable {
  /// {@macro drive_mode_settings}
  const DriveModeSettings({
    required this.throttle,
    required this.regen,
    required this.steering,
    required this.suspension,
    required this.climate,
  });

  /// How much energy the softest throttle setting saves over the middle
  /// one, and the sharpest costs, per position.
  static const _throttleWeightPerStep = 0.045;

  /// What one position of regen is worth. Less than throttle: regen only
  /// recovers energy already spent, where the throttle decides how much is
  /// spent in the first place.
  static const _regenWeightPerStep = 0.035;

  /// What one position of climate is worth. The smallest of the three:
  /// heating a cabin is a real draw, but a steady one that does not scale
  /// with how the car is being driven.
  static const _climateWeightPerStep = 0.030;

  final int throttle;
  final int regen;
  final int steering;
  final int suspension;
  final int climate;

  /// The position [parameter] is at.
  int valueOf(DriveModeParameter parameter) => switch (parameter) {
    DriveModeParameter.throttle => throttle,
    DriveModeParameter.regen => regen,
    DriveModeParameter.steering => steering,
    DriveModeParameter.suspension => suspension,
    DriveModeParameter.climate => climate,
  };

  /// A copy with [parameter] moved to [value], clamped to the positions
  /// that exist.
  DriveModeSettings withValue(DriveModeParameter parameter, int value) {
    final position = value.clamp(0, DriveModeParameter.steps - 1);
    return switch (parameter) {
      DriveModeParameter.throttle => copyWith(throttle: position),
      DriveModeParameter.regen => copyWith(regen: position),
      DriveModeParameter.steering => copyWith(steering: position),
      DriveModeParameter.suspension => copyWith(suspension: position),
      DriveModeParameter.climate => copyWith(climate: position),
    };
  }

  /// What the battery is worth in these settings, against the same battery
  /// in the middle position of everything.
  ///
  /// One formula for all five modes rather than a figure written against
  /// each: a mode the driver built themselves is then quoted the same way a
  /// named one is, and the two can never drift apart.
  ///
  /// Steering and suspension do not appear. Neither moves enough energy to
  /// show up next to the three that do, and claiming otherwise would put a
  /// number on the panel that nothing stands behind.
  double get rangeFactor {
    const middle = DriveModeParameter.middle;
    return 1 +
        _throttleWeightPerStep * (middle - throttle) +
        _regenWeightPerStep * (regen - middle) +
        _climateWeightPerStep * (middle - climate);
  }

  DriveModeSettings copyWith({
    int? throttle,
    int? regen,
    int? steering,
    int? suspension,
    int? climate,
  }) {
    return DriveModeSettings(
      throttle: throttle ?? this.throttle,
      regen: regen ?? this.regen,
      steering: steering ?? this.steering,
      suspension: suspension ?? this.suspension,
      climate: climate ?? this.climate,
    );
  }

  @override
  List<Object?> get props => [throttle, regen, steering, suspension, climate];
}
