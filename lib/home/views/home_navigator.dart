import 'package:agl_ivi_vgv_demo/home/home.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Hosts [HomePage] — or [AppsPage], whichever the home button last asked
/// for — in its own [Navigator].
///
/// A card overlay pushed through this navigator only fills the space given
/// to `HomeNavigator` rather than the whole app, so anything rendered
/// outside of it — namely `PermanentControlsPanel`, with the HVAC controls —
/// stays visible and interactive underneath.
class HomeNavigator extends StatelessWidget {
  const HomeNavigator({super.key});

  /// Reaches this navigator from outside the area it occupies.
  ///
  /// The cards push their own overlays through their local [Navigator],
  /// but `SettingsButton` sits in `PermanentControlsPanel`, below and
  /// outside this navigator, and would otherwise only find the root one —
  /// whose routes cover the HVAC controls. The home button beside it
  /// reaches in through the same key, to clear whatever a card has pushed
  /// before swapping the page underneath it.
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      // A nested Navigator gets no HeroController of its own by default (only
      // the app's top-level one does), so card overlays wouldn't animate as
      // Heroes without this.
      observers: [HeroController()],
      onGenerateRoute: (settings) =>
          MaterialPageRoute<void>(builder: (_) => const _HomeRoot()),
    );
  }
}

/// The navigator's bottom route: the dashboard or the launcher.
///
/// They swap in place rather than one being pushed over the other, so the
/// card overlays either of them opens are always exactly one route deep and
/// the home button has a single thing to undo.
class _HomeRoot extends StatelessWidget {
  const _HomeRoot();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewCubit, HomeView>(
      builder: (context, view) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (view) {
            HomeView.dashboard => const HomePage(key: ValueKey('dashboard')),
            HomeView.apps => const AppsPage(key: ValueKey('apps')),
          },
        );
      },
    );
  }
}
