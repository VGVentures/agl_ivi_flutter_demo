import 'package:agl_ui/agl_ui.dart';

/// {@template card_touch_target}
/// Makes [child] tappable, giving it an ink ripple clipped to
/// [borderRadius].
///
/// Wrap any dashboard card with this to declare the whole card a touch
/// target without changing the card's own implementation.
/// {@endtemplate}
class CardTouchTarget extends StatelessWidget {
  /// {@macro card_touch_target}
  const CardTouchTarget({
    required this.onTap,
    required this.child,
    this.borderRadius = 38,
    super.key,
  });

  /// Called when the card is tapped.
  final VoidCallback onTap;

  /// The card being wrapped.
  final Widget child;

  /// The corner radius of the ink ripple, matching the wrapped card's own
  /// [AppCardStyle.borderRadius].
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: child,
      ),
    );
  }
}
