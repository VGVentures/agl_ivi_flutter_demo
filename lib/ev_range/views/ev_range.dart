import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ivi_vgv_demo/powertrain/powertrain.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EvRange extends StatelessWidget {
  const EvRange({this.telemetry = PowertrainTelemetry.demo, super.key});

  final PowertrainTelemetry telemetry;

  @override
  Widget build(BuildContext context) {
    // What the pack is worth depends on how the car is being driven, so the
    // figure is read off the cubit the Drive Mode panel writes rather than
    // fixed here: picking Sport leaves this card quoting Sport's range.
    final range = context.select<DriveModeCubit, int>(
      (cubit) => cubit.state.estimatedRange,
    );
    return EvRangeCard(
      title: 'EV RANGE',
      percentage: telemetry.batteryPercent,
      remainingRange: range,
      rangeUnits: 'mi',
    );
  }
}
