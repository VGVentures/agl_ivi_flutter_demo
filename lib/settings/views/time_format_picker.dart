import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Picks how the clock card and the calendar agenda write times, listing
/// every [AppTimeFormat] as a tile so the choice reads the same way as the
/// theme and location pickers'.
class TimeFormatPicker extends StatelessWidget {
  const TimeFormatPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.appSpacing.md,
      runSpacing: context.appSpacing.md,
      children: [
        for (final format in AppTimeFormat.values)
          _TimeFormatOption(timeFormat: format),
      ],
    );
  }
}

class _TimeFormatOption extends StatelessWidget {
  const _TimeFormatOption({required this.timeFormat});

  final AppTimeFormat timeFormat;

  static const _tileWidth = 260.0;

  @override
  Widget build(BuildContext context) {
    final selected = context.select<AppBloc, bool>(
      (bloc) => bloc.state.timeFormat == timeFormat,
    );
    final theme = Theme.of(context);
    final accent = theme.extension<AppAccentTheme>()!.color;
    final foreground = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return CardTouchTarget(
      borderRadius: 24,
      onTap: () => context.read<AppBloc>().add(TimeFormatSelected(timeFormat)),
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
                    timeFormat.label,
                    style: theme.textTheme.headlineSmall,
                  ),
                  // The same instant written the way this tile would write
                  // it, so the label is backed by what it actually does.
                  Text(
                    timeFormat.example,
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
