import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Picks the units the weather card and its panel report readings in,
/// listing every [AppUnitSystem] as a tile so the choice reads the same way
/// as the theme, location and time format pickers'.
class UnitSystemPicker extends StatelessWidget {
  const UnitSystemPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.appSpacing.md,
      runSpacing: context.appSpacing.md,
      children: [
        for (final system in AppUnitSystem.values)
          _UnitSystemOption(unitSystem: system),
      ],
    );
  }
}

class _UnitSystemOption extends StatelessWidget {
  const _UnitSystemOption({required this.unitSystem});

  final AppUnitSystem unitSystem;

  /// Wider than the other pickers' tiles: "International System" is a
  /// longer name than any theme, city or clock format, and wrapping it
  /// would leave this tile taller than the one beside it.
  static const _tileWidth = 320.0;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<AppBloc, bool>(
      (bloc) => bloc.state.unitSystem == unitSystem,
    );
    final theme = Theme.of(context);
    final accent = theme.extension<AppAccentTheme>()!.color;
    final foreground = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return CardTouchTarget(
      borderRadius: 24,
      onTap: () => context.read<AppBloc>().add(UnitSystemSelected(unitSystem)),
      child: Container(
        width: _tileWidth,
        padding: EdgeInsets.all(context.appSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? accent : Colors.grey.withValues(alpha: 0.4),
            width: selected ? 3 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unitSystem.label,
                    style: theme.textTheme.headlineSmall,
                  ),
                  // One reading written the way this tile would write it,
                  // so the label is backed by what it actually does.
                  Text(
                    unitSystem.example,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: foreground.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (selected) Icon(Icons.check, color: accent),
          ],
        ),
      ),
    );
  }
}
