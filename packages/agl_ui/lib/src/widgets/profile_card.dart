import 'dart:ui';

import 'package:agl_ui/agl_ui.dart';

class ProfileStyleCard extends ThemeExtension<ProfileStyleCard> {
  const ProfileStyleCard({
    required this.backgroundColor,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final double borderRadius;

  @override
  ProfileStyleCard copyWith({
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return ProfileStyleCard(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  ProfileStyleCard lerp(
    covariant ThemeExtension<ProfileStyleCard>? other,
    double t,
  ) {
    if (other is! ProfileStyleCard) {
      return this;
    }
    return ProfileStyleCard(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}

/// A driver's portrait on the circle it is always drawn on.
///
/// The one place the treatment is decided, so a portrait reads the same on
/// the card, at the head of a panel and down a list of drivers.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    required this.assetName,
    required this.background,
    required this.size,
    super.key,
  });

  /// The portrait, as an SVG asset path.
  final String assetName;

  /// The circle the portrait is drawn on.
  final Color background;

  /// The diameter of that circle.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: background),
      // Clipped as well as drawn round: the portraits are cropped to the
      // circle themselves, and a clip here keeps one that is not from
      // spilling over the edge.
      child: ClipOval(
        child: SvgPicture.asset(assetName, width: size, height: size),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    required this.name,
    required this.avatarAsset,
    required this.avatarBackground,
    super.key,
  });

  /// The size the portrait is drawn at on the card.
  static const avatarSize = 50.0;

  final String name;

  /// The portrait, as an SVG asset path.
  ///
  /// A drawn portrait rather than a glyph: the card sits on a head unit
  /// beside a driver's own name, and a smiley there reads as a placeholder
  /// however good the rest of the screen is.
  final String avatarAsset;

  /// What the portrait is drawn on. The portraits are cut out, so this is
  /// the backdrop they are seen against rather than a fallback.
  final Color avatarBackground;

  @override
  Widget build(BuildContext context) {
    final style = context.profileStyleCard;
    final textColor = style.backgroundColor
        .blackOrWhiteAccessibleContrastColor();
    final ts = Theme.of(
      context,
    ).textTheme.bodyLarge!.copyWith(color: textColor);
    return Card(
      color: style.backgroundColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name.toUpperCase(), style: ts),
            ProfileAvatar(
              assetName: avatarAsset,
              background: avatarBackground,
              size: avatarSize,
            ),
          ],
        ),
      ),
    );
  }
}
