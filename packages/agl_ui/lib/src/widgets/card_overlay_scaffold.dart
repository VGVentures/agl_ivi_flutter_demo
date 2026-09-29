import 'package:agl_ui/agl_ui.dart';

/// The floating chrome every card overlay shares.
///
/// Pads [child] away from the top, left and right edges — painted in the
/// app's own background, not the home page, so cards outside the overlay
/// never show through — while the bottom sits flush so nothing intrudes on
/// the HVAC controls below. Paints [background] behind [child], clipped to
/// [borderRadius] on all four corners (the home screen's common card
/// radius, not the tapped card's own — so every overlay reads as the same
/// kind of surface). A close button sits in the top-left corner.
///
/// The panel is wrapped in a [Hero] tagged [heroTag], so — given a matching
/// [Hero] on the card that opened it — it flies in from that card's exact
/// position and size instead of just appearing, like the card inflating
/// into the overlay.
class CardOverlayScaffold extends StatelessWidget {
  const CardOverlayScaffold({
    required this.background,
    required this.child,
    required this.heroTag,
    this.sourceBackground,
    this.borderRadius = 30,
    super.key,
  });

  /// Painted behind [child] once the overlay is open.
  final Decoration background;

  /// The tapped card's own decoration, which [background] is tweened out of
  /// as the overlay opens and back into as it closes.
  ///
  /// Leave `null`, or pass the same decoration as [background], when the
  /// overlay keeps the card's color and there is nothing to tween.
  final Decoration? sourceBackground;

  /// The overlay's content, laid out beneath the close button.
  final Widget child;

  /// Matches the [Hero] tag of the card this overlay was opened from.
  final Object heroTag;

  /// The corner radius applied to all four corners.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(
            top: context.appSpacing.md,
            left: context.appSpacing.md,
            child: const _CloseButton(),
          ),
        ],
      ),
    );

    final source = sourceBackground;
    return Scaffold(
      // Opaque so the padding around the panel reads as the home screen's
      // own backdrop rather than a window onto the cards behind it.
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: EdgeInsetsDirectional.only(
          top: context.appSpacing.md,
          start: context.appSpacing.md,
          end: context.appSpacing.md,
        ),
        child: Hero(
          tag: heroTag,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: source == null || source == background
                ? _Surface(decoration: background, child: body)
                : _AnimatedSurface(
                    from: source,
                    to: background,
                    // Captured here rather than looked up further down: the
                    // Hero flight re-parents this subtree into the
                    // navigator's overlay, where the route's own
                    // inherited widgets are out of reach.
                    animation:
                        ModalRoute.of(context)?.animation ??
                        kAlwaysCompleteAnimation,
                    child: body,
                  ),
          ),
        ),
      ),
    );
  }
}

/// The control that dismisses an overlay.
///
/// Takes its color from the panel's own resolved foreground rather than the
/// theme's color scheme, so it holds the same contrast against the surface
/// that the content does, whatever the card underneath is painted with.
/// Reading it from the ambient [IconTheme] also means it tracks the
/// interpolated color while [_AnimatedSurface] crossfades, instead of
/// sitting at one end of the flight.
class _CloseButton extends StatelessWidget {
  const _CloseButton();

  /// How far the button's fill lifts off the surface behind it. Enough to
  /// read as a control, low enough that the icon stays the thing you see.
  static const _fillOpacity = 0.15;

  @override
  Widget build(BuildContext context) {
    final foreground =
        IconTheme.of(context).color ?? Theme.of(context).colorScheme.onSurface;
    return IconButton(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close),
      style: IconButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: foreground.withValues(alpha: _fillOpacity),
      ),
    );
  }
}

/// Paints [decoration] behind [child] and picks the text color to read
/// against it.
class _Surface extends StatelessWidget {
  const _Surface({required this.decoration, required this.child});

  final Decoration decoration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: decoration,
      child: ForegroundColorOverride(
        color: decoration.foregroundContrastColor,
        child: child,
      ),
    );
  }
}

/// Crossfades the panel's surface from [from] to [to] as [animation] runs,
/// so a card that opens onto a different color deepens into it while it
/// grows rather than swapping the instant the route is pushed.
///
/// Layered rather than interpolated: [to] is painted underneath at full
/// strength and [from] fades out over it. Interpolating the two
/// decorations directly only holds when both paint the same way — two
/// flat colors lerp cleanly, but a card painted in a gradient opening onto
/// a flat color has no color on one side and no gradient on the other, so
/// `Decoration.lerp` fades each towards transparent and the panel goes
/// half see-through in the middle of the flight, flashing whatever the
/// route is growing over. Fading one opaque layer over another lands on
/// the same colors for the flat-to-flat case and stays opaque for the
/// rest.
class _AnimatedSurface extends StatelessWidget {
  const _AnimatedSurface({
    required this.animation,
    required this.from,
    required this.to,
    required this.child,
  });

  final Animation<double> animation;
  final Decoration from;
  final Decoration to;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        return DecoratedBox(
          decoration: to,
          child: DecoratedBox(
            // Lerping towards nothing scales the decoration's own alpha,
            // which keeps the fade in the painted colors instead of
            // costing an `Opacity` layer every frame of the flight.
            decoration: Decoration.lerp(from, null, t)!,
            child: ForegroundColorOverride(
              color: _lerpForeground(
                from.foregroundContrastColor,
                to.foregroundContrastColor,
                t,
              ),
              child: child!,
            ),
          ),
        );
      },
    );
  }

  /// A decoration with no flat color of its own contributes no contrast
  /// color, so there is nothing to interpolate towards: the side that has
  /// one takes over at the halfway point instead of fading through
  /// transparent.
  static Color? _lerpForeground(Color? a, Color? b, double t) {
    if (a == null || b == null) return t < 0.5 ? a : b;
    return Color.lerp(a, b, t);
  }
}
