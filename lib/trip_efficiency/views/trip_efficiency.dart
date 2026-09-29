import 'package:agl_ivi_vgv_demo/powertrain/powertrain.dart';
import 'package:agl_ui/agl_ui.dart';

class TripEfficiency extends StatelessWidget {
  const TripEfficiency({this.telemetry = PowertrainTelemetry.demo, super.key});

  final PowertrainTelemetry telemetry;

  @override
  Widget build(BuildContext context) {
    return TripEfficiencyCard(
      title: 'EFFICIENCY',
      // The same trips the panel plots, so the card and the chart it opens
      // cannot fall out of step.
      batteryConsumption: [
        for (final trip in telemetry.trips) (trip.label, trip.batteryPercent),
      ],
    );
  }
}
