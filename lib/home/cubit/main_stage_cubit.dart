import 'package:bloc/bloc.dart';

/// What the large tile on the left of the home grid is showing.
enum MainStageView {
  /// The navigation map, shown first: it is the view a driver wants up by
  /// default, and it leaves the 3D scene's GPU cost unpaid until asked for.
  map,

  /// The 3D car scene.
  scene,
}

/// {@template main_stage_cubit}
/// Manages which view occupies the main stage of the home grid.
///
/// Lives above both the home grid and the permanent controls, because the
/// menu panel's snowflake button toggles a view the home grid renders.
/// {@endtemplate}
class MainStageCubit extends Cubit<MainStageView> {
  /// {@macro main_stage_cubit}
  MainStageCubit() : super(MainStageView.map);

  /// Switches between the map and the 3D scene.
  void toggle() => emit(
    state == MainStageView.map ? MainStageView.scene : MainStageView.map,
  );
}
