import 'dart:math' as math;

import 'package:agl_ui/agl_ui.dart';

/// Lays [child] out at [size] in whichever direction there is less room
/// than that, and crops what does not fit, instead of handing it
/// constraints it cannot honor.
///
/// Card overlays are laid out at the tapped card's own size while the Hero
/// flight is still running, which is far below what their content reads at.
/// Rather than let a panel squeeze until it overflows, it opens onto its
/// finished layout and is cropped on the way — so it looks like the card is
/// growing to reveal the panel rather than the panel rearranging itself.
class MinimumContentSize extends StatelessWidget {
  const MinimumContentSize({
    required this.size,
    required this.child,
    super.key,
  });

  /// The smallest [child] is laid out at.
  final Size size;

  /// The content being kept at [size].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.max(constraints.maxWidth, size.width);
        final height = math.max(constraints.maxHeight, size.height);
        if (width == constraints.maxWidth && height == constraints.maxHeight) {
          return child;
        }
        return ClipRect(
          child: OverflowBox(
            alignment: AlignmentDirectional.topStart,
            minWidth: width,
            maxWidth: width,
            minHeight: height,
            maxHeight: height,
            child: child,
          ),
        );
      },
    );
  }
}
