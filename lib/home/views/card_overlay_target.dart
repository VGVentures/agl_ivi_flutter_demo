import 'package:agl_ui/agl_ui.dart';

/// Wraps a dashboard [child] so tapping it pushes [contentBuilder] as a
/// floating overlay on the nearest [Navigator], keeping [background]
/// consistent with the card it was opened from.
///
/// [child] is wrapped in a [Hero] tagged [heroTag] shared with
/// [CardOverlayScaffold], so the overlay grows out of the tapped card's own
/// position and size — a container-transform "genie" effect — instead of
/// just appearing over it.
///
/// `HomeNavigator` scopes that navigator to the home page's own area, so the
/// pushed page overlays the cards without covering the HVAC controls, and
/// gives it the `HeroController` this flight needs.
class CardOverlayTarget extends StatelessWidget {
  const CardOverlayTarget({
    required this.background,
    required this.contentBuilder,
    required this.child,
    required this.heroTag,
    this.overlayBackground,
    this.borderRadius = 38,
    super.key,
  });

  /// The tapped card's own background, which the overlay grows out of.
  final Decoration background;

  /// The decoration the opened overlay settles on, if the card's own color
  /// does not work at panel scale. Defaults to [background].
  ///
  /// Pass `AppCardStyle.overlaySurface` for a card styled through
  /// [AppCardTheme]; it already resolves this fallback.
  final Decoration? overlayBackground;

  /// Builds the overlay's content, below the chrome (padding, rounding,
  /// close button) that [CardOverlayScaffold] provides.
  final WidgetBuilder contentBuilder;

  /// The card being made tappable.
  final Widget child;

  /// Ties this card to its overlay for the [Hero] flight between them. Must
  /// be unique among the cards on screen at once.
  final Object heroTag;

  /// The corner radius of the ink ripple, matching the tapped card's own
  /// shape. The pushed overlay uses its own fixed radius instead — see
  /// [CardOverlayScaffold.borderRadius] — so it stays consistent across
  /// every card.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return CardTouchTarget(
      borderRadius: borderRadius,
      onTap: () => Navigator.of(context).push(_buildRoute()),
      child: Hero(tag: heroTag, child: child),
    );
  }

  PageRouteBuilder<void> _buildRoute() {
    final overlayBackground = this.overlayBackground ?? background;
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (context, animation, secondaryAnimation) =>
          CardOverlayScaffold(
            background: overlayBackground,
            sourceBackground: background,
            heroTag: heroTag,
            child: Builder(builder: contentBuilder),
          ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // The panel's own motion comes from the Hero flight; this only
        // fades in the backdrop around it.
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
          child: child,
        );
      },
    );
  }
}
