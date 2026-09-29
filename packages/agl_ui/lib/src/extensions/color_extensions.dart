import 'package:agl_ui/agl_ui.dart';

extension AppColorExtension on Color {
  Color blackOrWhiteAccessibleContrastColor({double threshold = 0.5}) =>
      computeLuminance() > threshold ? Colors.black : Colors.white;
}

/// Picks a readable text color for a flat-colored [Decoration], leaving
/// gradients and images to the ambient theme's default.
extension AppDecorationExtension on Decoration {
  /// Black or white, whichever reads against this decoration's own color,
  /// or `null` when it paints no flat color to measure.
  Color? get foregroundContrastColor {
    final self = this;
    if (self is BoxDecoration && self.color != null) {
      return self.color!.blackOrWhiteAccessibleContrastColor();
    }
    return null;
  }
}
