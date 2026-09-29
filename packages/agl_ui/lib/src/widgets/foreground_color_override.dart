import 'package:agl_ui/agl_ui.dart';

/// Overrides the ambient [Theme]'s text color for [child] when [color] is
/// non-null, so a card or overlay can opt into a different text color
/// without every [Text] beneath it having to set one itself.
class ForegroundColorOverride extends StatelessWidget {
  const ForegroundColorOverride({
    required this.color,
    required this.child,
    super.key,
  });

  final Color? color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (color == null) return child;

    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          bodyColor: color,
          displayColor: color,
        ),
        iconTheme: theme.iconTheme.copyWith(color: color),
      ),
      child: child,
    );
  }
}
