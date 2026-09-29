import 'dart:ui';

import 'package:agl_ui/agl_ui.dart';

/// {@template app_card_style}
/// The visual treatment of a single card.
///
/// [background] is a [Decoration], so a card can be painted with a solid
/// color (`BoxDecoration(color: ...)`), a gradient
/// (`BoxDecoration(gradient: ...)`), or an image without changing its type.
///
/// Instances live in [AppCardTheme] rather than being built at the call site,
/// so card colors are defined in one place.
/// {@endtemplate}
@immutable
class AppCardStyle {
  /// {@macro app_card_style}
  const AppCardStyle({
    required this.background,
    this.borderRadius = 38,
    this.foregroundColor,
    this.overlayBackground,
    this.accentColor,
  });

  /// Painted behind the card's contents and clipped to [borderRadius].
  final Decoration background;

  /// Painted behind the card's full-screen overlay, in place of
  /// [background].
  ///
  /// A card's color is chosen at tile scale, where a saturated block reads
  /// as one accent among several. Covering a whole panel with that same
  /// color leaves nothing to contrast against, so a card whose [background]
  /// is an accent rather than a surface sets a calmer one here. Leave it
  /// `null` when [background] already works at panel scale; the overlay
  /// then keeps the card's own color. Read it through [overlaySurface]
  /// rather than directly.
  final Decoration? overlayBackground;

  /// The radius applied to all four corners.
  ///
  /// Kept separate from [background] so the card's clip and the painted
  /// decoration cannot fall out of sync.
  final double borderRadius;

  /// Overrides the color of the title and content text.
  ///
  /// Leave `null` to keep the theme's default text color. Set this when
  /// [background] is dark or saturated enough that the default text color
  /// no longer reads clearly against it.
  final Color? foregroundColor;

  /// The color the card's overlay picks out its section labels in.
  ///
  /// A panel's labels tie it back to the card it grew out of, which the
  /// app's own accent already does for a card painted in something close to
  /// it. Set this when the card's identity is a different color — a yellow
  /// weather card opening under a green accent — and leave it `null`
  /// otherwise. Resolve it with [accentColorOr].
  final Color? accentColor;

  /// The decoration the card's overlay paints, falling back to
  /// [background] when the card needs no separate overlay surface.
  Decoration get overlaySurface => overlayBackground ?? background;

  /// This card's own [accentColor], or [fallback] — the app's accent — when
  /// it names none.
  Color accentColorOr(Color fallback) => accentColor ?? fallback;

  /// Returns a copy of this style with the given fields replaced.
  AppCardStyle copyWith({
    Decoration? background,
    double? borderRadius,
    Color? foregroundColor,
    Decoration? overlayBackground,
    Color? accentColor,
  }) {
    return AppCardStyle(
      background: background ?? this.background,
      borderRadius: borderRadius ?? this.borderRadius,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      overlayBackground: overlayBackground ?? this.overlayBackground,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  /// Linearly interpolates towards [other].
  AppCardStyle lerp(AppCardStyle other, double t) {
    return AppCardStyle(
      background: Decoration.lerp(background, other.background, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      // Interpolating the resolved surfaces rather than the raw fields
      // keeps a style that falls back to [background] lerping against one
      // that does not, instead of fading in from nothing. Both sides
      // unset stays unset, so the endpoints compare equal to their
      // originals.
      overlayBackground:
          overlayBackground == null && other.overlayBackground == null
          ? null
          : Decoration.lerp(overlaySurface, other.overlaySurface, t),
      accentColor: Color.lerp(accentColor, other.accentColor, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppCardStyle &&
        other.background == background &&
        other.borderRadius == borderRadius &&
        other.foregroundColor == foregroundColor &&
        other.overlayBackground == overlayBackground &&
        other.accentColor == accentColor;
  }

  @override
  int get hashCode => Object.hash(
    background,
    borderRadius,
    foregroundColor,
    overlayBackground,
    accentColor,
  );
}
