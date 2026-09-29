import 'package:agl_ui/agl_ui.dart';

/// {@template app_icon}
/// Renders an [AppIconData] value (e.g. `AppIcons.iconFan`), picking the
/// right underlying widget (SVG or Material) automatically.
///
/// [size] and [color] default to the ambient [IconTheme] when omitted.
/// {@endtemplate}
class AppIcon extends StatelessWidget {
  /// {@macro app_icon}
  const AppIcon(this.data, {super.key, this.size, this.color});

  /// The icon to render.
  final AppIconData data;

  /// Overrides the icon size. Defaults to [IconThemeData.size].
  final double? size;

  /// Overrides the icon color. Defaults to [IconThemeData.color].
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return data.build(
      size: size ?? iconTheme.size,
      color: color ?? iconTheme.color,
    );
  }
}
