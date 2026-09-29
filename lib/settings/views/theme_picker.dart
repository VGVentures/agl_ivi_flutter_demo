import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Picks the app theme, showing every [AppThemeId] as a tile painted in that
/// theme's own colors so the choice reads as a preview rather than a label.
class ThemePicker extends StatelessWidget {
  const ThemePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.appSpacing.md,
      runSpacing: context.appSpacing.md,
      children: [
        for (final id in AppThemeId.values) _ThemeOption(themeId: id),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({required this.themeId});

  final AppThemeId themeId;

  static const _tileWidth = 260.0;
  static const _swatchSize = 28.0;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<AppBloc, bool>(
      (bloc) => bloc.state.themeId == themeId,
    );
    // The tile paints itself in the theme it offers, so its colors come from
    // that theme rather than the one currently applied.
    final preview = AppTheme.themeFor(themeId);
    final accent = preview.extension<AppAccentTheme>()!.color;
    final cards = preview.extension<AppCardTheme>()!;
    final labelColor = preview.textTheme.bodyLarge?.color;

    return CardTouchTarget(
      borderRadius: 24,
      onTap: () => context.read<AppBloc>().add(ThemeSelected(themeId)),
      child: Container(
        width: _tileWidth,
        padding: EdgeInsets.all(context.appSpacing.md),
        decoration: BoxDecoration(
          color: preview.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? accent : Colors.grey.withValues(alpha: 0.4),
            width: selected ? 3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              spacing: context.appSpacing.xs,
              children: [
                for (final color in [
                  accent,
                  ...[
                    cards.calendar,
                    cards.weather,
                    cards.evRange,
                  ].map((style) => style.background).whereFlatColor(),
                ])
                  Container(
                    width: _swatchSize,
                    height: _swatchSize,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.appSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    themeId.label,
                    style: preview.textTheme.headlineSmall?.copyWith(
                      color: labelColor,
                    ),
                  ),
                ),
                if (selected) Icon(Icons.check, color: accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension on Iterable<Decoration> {
  /// Keeps only the flat-colored decorations, since a gradient or image has
  /// no single color to show as a swatch.
  Iterable<Color> whereFlatColor() =>
      whereType<BoxDecoration>().map((decoration) => decoration.color).nonNulls;
}
