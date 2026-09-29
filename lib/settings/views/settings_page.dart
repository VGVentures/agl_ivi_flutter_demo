import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';

/// The full-screen settings overlay, opened from [SettingsButton].
///
/// It is pushed on `HomeNavigator`, so it overlays the home screen's cards
/// and leaves the HVAC controls below it visible, the same way a card's own
/// overlay does. Sections are stacked in a scroll view so the page has room
/// to grow beyond the theme picker.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  /// Unlike a card overlay, this page has no [Hero] to fly from: the button
  /// that opens it lives outside `HomeNavigator`, where the flight could
  /// never find it. The tag still keeps the panel distinct from the cards'.
  static const _heroTag = 'settings-panel';

  /// Clears the close button [CardOverlayScaffold] paints over the content's
  /// top-left corner.
  static const _closeButtonClearance = 80.0;

  /// The route that presents this page.
  static Route<void> route() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => const SettingsPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Standing in for the card overlays' Hero flight: the panel swells
        // into place instead of growing out of the card that opened it.
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curve,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.94, end: 1).animate(curve),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Read at build time rather than captured when the route was pushed, so
    // picking a theme from inside the page restyles the page itself.
    final style = context.appCardTheme.settings;
    return CardOverlayScaffold(
      background: style.background,
      borderRadius: style.borderRadius,
      heroTag: _heroTag,
      child: const _SettingsBody(),
    );
  }
}

/// The page's own content, kept in its own widget so it builds below the
/// text color [CardOverlayScaffold] sets for the panel — a [Text] style
/// resolved in [SettingsPage.build] would still be the home screen's.
class _SettingsBody extends StatelessWidget {
  const _SettingsBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.appSpacing.xlg,
        SettingsPage._closeButtonClearance,
        context.appSpacing.xlg,
        context.appSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: Theme.of(context).textTheme.displayMedium),
          SizedBox(height: context.appSpacing.lg),
          const Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SettingsSection(title: 'Theme', child: ThemePicker()),
                  SettingsSection(
                    title: 'Location',
                    child: LocationPicker(),
                  ),
                  SettingsSection(
                    title: 'Time format',
                    child: TimeFormatPicker(),
                  ),
                  SettingsSection(
                    title: 'Units',
                    child: UnitSystemPicker(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One titled block of settings, so every section on [SettingsPage] is
/// spaced and labelled the same way.
class SettingsSection extends StatelessWidget {
  const SettingsSection({required this.title, required this.child, super.key});

  /// The section heading.
  final String title;

  /// The section's controls.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.appSpacing.xlg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          SizedBox(height: context.appSpacing.md),
          child,
        ],
      ),
    );
  }
}
