import 'package:agl_ui/agl_ui.dart';

/// The raised surface every block inside a card overlay sits on.
///
/// Tints the ambient text color rather than naming a fixed fill, so one
/// treatment reads correctly on whatever color the panel underneath is
/// painted — a deepened green calendar, a deepened amber weather panel — in
/// either theme. [child] is laid out edge to edge; pad it yourself.
class PanelSurface extends StatelessWidget {
  const PanelSurface({
    required this.child,
    this.emphasized = false,
    this.borderRadius = defaultBorderRadius,
    super.key,
  });

  /// The block this surface sits behind.
  final Widget child;

  /// Lifts the surface further off the panel, marking the one block the
  /// eye should land on first.
  final bool emphasized;

  /// The radius applied to all four corners.
  final double borderRadius;

  /// The corner radius shared by every block on a panel.
  static const defaultBorderRadius = 18.0;

  @override
  Widget build(BuildContext context) {
    final foreground =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: emphasized ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
