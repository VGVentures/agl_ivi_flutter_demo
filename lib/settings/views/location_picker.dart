import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Picks the city the weather, calendar and map cards report on, listing every
/// [AppLocation] as a tile so the choice reads the same way as the
/// theme picker's.
class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.appSpacing.md,
      runSpacing: context.appSpacing.md,
      children: [
        for (final location in AppLocation.values)
          _LocationOption(location: location),
      ],
    );
  }
}

class _LocationOption extends StatelessWidget {
  const _LocationOption({required this.location});

  final AppLocation location;

  static const _tileWidth = 260.0;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<AppBloc, bool>(
      (bloc) => bloc.state.location == location,
    );
    final theme = Theme.of(context);
    final accent = theme.extension<AppAccentTheme>()!.color;

    return CardTouchTarget(
      borderRadius: 24,
      onTap: () => context.read<AppBloc>().add(LocationSelected(location)),
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
              child: Text(location.label, style: theme.textTheme.headlineSmall),
            ),
            if (selected) Icon(Icons.check, color: accent),
          ],
        ),
      ),
    );
  }
}
