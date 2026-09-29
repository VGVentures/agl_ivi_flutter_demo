import 'package:agl_ivi_vgv_demo/hvac/hvac.dart';
import 'package:agl_ivi_vgv_demo/menu/menu.dart';
import 'package:agl_ui/agl_ui.dart';

class PermanentControlsPanel extends StatelessWidget {
  const PermanentControlsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          HvacPanel(),
          MenuPanel(),
          HvacPanel(isOnDriverSide: false),
        ],
      ),
    );
  }
}
