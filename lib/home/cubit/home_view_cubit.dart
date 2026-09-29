import 'package:bloc/bloc.dart';

/// What fills the area above the permanent controls.
enum HomeView {
  /// The dashboard of cards.
  dashboard,

  /// The launcher, listing the apps the dashboard does not have a card for.
  apps,
}

/// {@template home_view_cubit}
/// Manages whether the home screen or the app launcher is showing.
///
/// Lives above `HomeNavigator` rather than inside it, because the home
/// button that flips between them sits in the permanent controls strip,
/// outside the navigator whose page it swaps.
/// {@endtemplate}
class HomeViewCubit extends Cubit<HomeView> {
  /// {@macro home_view_cubit}
  HomeViewCubit() : super(HomeView.dashboard);

  /// Switches between the dashboard and the launcher.
  void toggle() => emit(
    state == HomeView.dashboard ? HomeView.apps : HomeView.dashboard,
  );
}
