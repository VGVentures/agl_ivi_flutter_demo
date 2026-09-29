import 'package:agl_ui/agl_ui.dart';

/// {@template app_launcher_card}
/// One entry on the app launcher: an app's [icon] above its [label].
///
/// Paints [background] clipped to [borderRadius] and picks the foreground
/// that reads against it, so a launcher tile is painted in the same color
/// as the card the same app occupies on the home screen and the overlay it
/// opens grows out of a surface the driver recognizes.
/// {@endtemplate}
class AppLauncherCard extends StatelessWidget {
  /// {@macro app_launcher_card}
  const AppLauncherCard({
    required this.icon,
    required this.label,
    required this.background,
    this.borderRadius = 38,
    super.key,
  });

  /// The glyph that stands for the app.
  final AppIconData icon;

  /// The app's name, written beneath [icon].
  final String label;

  /// Painted behind the tile's contents.
  final Decoration background;

  /// The radius applied to all four corners.
  final double borderRadius;

  /// Large enough to be the thing you aim at from the driver's seat, small
  /// enough to leave the name room beneath it.
  static const _iconSize = 72.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: background,
        child: ForegroundColorOverride(
          color: background.foregroundContrastColor,
          child: Padding(
            padding: EdgeInsets.all(context.appSpacing.md),
            child: Builder(
              // Below the override rather than beside it, so the icon and
              // the label both resolve the color it sets.
              builder: (context) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: context.appSpacing.md,
                children: [
                  AppIcon(icon, size: _iconSize),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
