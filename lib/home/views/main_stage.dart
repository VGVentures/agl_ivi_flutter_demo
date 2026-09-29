import 'package:agl_ivi_vgv_demo/home/cubit/main_stage_cubit.dart';
import 'package:agl_ivi_vgv_demo/home/views/card_overlay_target.dart';
import 'package:agl_ivi_vgv_demo/home/views/parked_car_scene.dart';
import 'package:agl_ivi_vgv_demo/map/map.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The large tile on the left of the home grid.
///
/// Shows either the map or the 3D scene, toggled by the snowflake button in
/// the menu panel. The map is what comes up first. It is tappable and
/// expands into a full screen overlay like the other cards; the scene is
/// not.
class MainStage extends StatelessWidget {
  const MainStage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainStageCubit, MainStageView>(
      builder: (context, view) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (view) {
            MainStageView.map => CardOverlayTarget(
              key: const ValueKey('map'),
              background: BoxDecoration(
                color: CityMap.backgroundColor(context),
              ),
              borderRadius: _mapBorderRadius,
              heroTag: 'map-card',
              contentBuilder: (_) => const CityMap.expanded(),
              child: const CityMap(),
            ),
            MainStageView.scene => const ParkedCarScene(key: ValueKey('scene')),
          },
        );
      },
    );
  }

  /// Matches the radius [CityMap] clips itself to, so the ink ripple
  /// follows the map's own corners.
  static const _mapBorderRadius = 30.0;
}
