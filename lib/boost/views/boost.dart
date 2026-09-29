import 'package:agl_ivi_vgv_demo/powertrain/powertrain.dart';
import 'package:agl_ui/agl_ui.dart';

class Boost extends StatelessWidget {
  const Boost({this.telemetry = PowertrainTelemetry.demo, super.key});

  final PowertrainTelemetry telemetry;

  @override
  Widget build(BuildContext context) {
    return BoostCard(
      title: 'BOOST',
      pressure: telemetry.boostPsi,
      units: 'psi',
    );
  }
}
