import 'package:agl_ui/agl_ui.dart';

/// One of the media player's transport controls, on the Music card and on
/// the panel it opens.
///
/// A control that is on — shuffle, repeat — and the play/pause button that
/// is always the primary action are filled with the player's accent and
/// drawn in whatever reads against it; the rest sit bare on the surface.
/// Filling rather than tinting is what keeps an on/off control legible in a
/// theme whose accent and icon color are the same, as the light theme's
/// are.
class MediaControlButton extends StatelessWidget {
  const MediaControlButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isActive = false,
    this.isPrimary = false,
    this.size = 64,
    this.iconSize = 28,
    super.key,
  });

  /// The glyph on the button.
  final AppIconData icon;

  /// Called when the control is pressed.
  final VoidCallback onPressed;

  /// Names the control for hover and for screen readers.
  final String tooltip;

  /// Whether the mode this control turns on is currently on.
  final bool isActive;

  /// Marks the one control the eye should land on first, which is filled
  /// whether or not it is [isActive].
  final bool isPrimary;

  /// The button's tap target, square.
  final double size;

  /// The glyph's size within it.
  final double iconSize;

  /// How long the fill takes to come and go. Long enough to read as the
  /// control answering the tap, short enough not to lag behind a driver
  /// toggling it twice.
  static const _fillDuration = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final style = context.musicPlayerStyleCard;
    final target = isPrimary || isActive ? 1.0 : 0.0;

    return Tooltip(
      message: tooltip,
      child: TweenAnimationBuilder<double>(
        // Starting at the target rather than at zero: a control that is
        // already on when the player is first laid out is on, not just
        // turning on.
        tween: Tween(begin: target, end: target),
        duration: _fillDuration,
        curve: Curves.easeOut,
        builder: (context, fill, _) {
          return IconButton(
            onPressed: onPressed,
            constraints: BoxConstraints.tightFor(width: size, height: size),
            style: IconButton.styleFrom(
              backgroundColor: Color.lerp(
                Colors.transparent,
                style.accentColor,
                fill,
              ),
              shape: const CircleBorder(),
            ),
            icon: AppIcon(
              icon,
              size: iconSize,
              // Crossfaded along with the fill, so the glyph is never the
              // wrong color for the ground it is sitting on mid-toggle.
              color: Color.lerp(
                style.iconColor,
                style.accentColor.blackOrWhiteAccessibleContrastColor(),
                fill,
              ),
            ),
          );
        },
      ),
    );
  }
}
