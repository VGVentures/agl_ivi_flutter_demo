import 'dart:ui';

import 'package:agl_ui/agl_ui.dart';

/// The projection systems a paired phone can hand the head unit.
///
/// The design system's own vocabulary: one glyph, one name and one color
/// each, so a phone's platform is drawn the same way on the card and in the
/// panel that picks it. Which handsets exist, and which of these each one
/// speaks, is the app's business and is attached there.
///
/// [accentColor] is the platform's own, not the theme's: the point of the
/// badge is that a driver picks CarPlay out of a list of phones by color
/// before reading a word, and that color cannot move with the theme without
/// losing exactly that.
enum PhoneProjection {
  carPlay(
    label: 'CarPlay',
    icon: AppIcons.carPlay,
    accentColor: Color(0xFF0A84FF),
  ),
  androidAuto(
    label: 'Android Auto',
    icon: AppIcons.androidAuto,
    accentColor: Color(0xFF3DDC84),
  );

  const PhoneProjection({
    required this.label,
    required this.icon,
    required this.accentColor,
  });

  /// The platform written out, for the card and the panel that names it.
  final String label;

  /// The mark that stands for it on the badge and in a list.
  final AppIconData icon;

  /// The color the badge is filled with and the panel picks its labels out
  /// in.
  final Color accentColor;
}

class PhoneStyleCard extends ThemeExtension<PhoneStyleCard> {
  const PhoneStyleCard({
    required this.backgroundColor,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final double borderRadius;

  @override
  PhoneStyleCard copyWith({
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return PhoneStyleCard(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  PhoneStyleCard lerp(
    covariant ThemeExtension<PhoneStyleCard>? other,
    double t,
  ) {
    if (other is! PhoneStyleCard) {
      return this;
    }
    return PhoneStyleCard(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}

/// The Phone tile: which handset is paired, and what it projects with.
///
/// Connecting a different phone crossfades the badge rather than swapping
/// it, so picking an Android in the panel arrives as the card turning into
/// the new phone.
class PhoneCard extends StatelessWidget {
  const PhoneCard({
    required this.phoneModel,
    required this.projection,
    super.key,
  });

  /// How long the badge takes to change platform.
  static const _projectionChange = Duration(milliseconds: 300);

  /// The paired handset, written out.
  final String phoneModel;

  /// What that handset hands the head unit.
  final PhoneProjection projection;

  @override
  Widget build(BuildContext context) {
    final style = context.phoneStyleCard;
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
            // The longest model name is half again the shortest, so the
            // two lines give way to the badge rather than pushing it off
            // the card.
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phoneModel,
                    style: ts,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    projection.label.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.6),
                      letterSpacing: 1.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: context.appSpacing.sm),
            AnimatedSwitcher(
              duration: _projectionChange,
              child: _ProjectionBadge(
                key: ValueKey(projection),
                projection: projection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The platform mark, on a disc filled with that platform's own color.
class _ProjectionBadge extends StatelessWidget {
  const _ProjectionBadge({required this.projection, super.key});

  /// The size of the disc, matching the circular controls elsewhere on the
  /// home screen.
  static const _diameter = 50.0;

  final PhoneProjection projection;

  @override
  Widget build(BuildContext context) {
    final accent = projection.accentColor;
    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent,
      ),
      child: Center(
        child: AppIcon(
          projection.icon,
          size: 28,
          color: accent.blackOrWhiteAccessibleContrastColor(),
        ),
      ),
    );
  }
}
