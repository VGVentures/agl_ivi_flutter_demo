import 'package:agl_ui/agl_ui.dart';

/// {@template app_card}
/// The shared shell every dashboard card is built from.
///
/// Lays out a [title] above [content], separated by
/// [MainAxisAlignment.spaceBetween] so the two sit at opposite ends of the
/// available height. The card paints [AppCardStyle.background] and clips it
/// to [AppCardStyle.borderRadius].
///
/// [AppCard] never reads the theme for its [style]; the calling card resolves
/// it from [AppCardTheme] and passes it down.
///
/// ```dart
/// AppCard(
///   style: context.appCardTheme.weather,
///   title: 'Chicago',
///   content: Text('72°', style: Theme.of(context).textTheme.displayLarge),
/// )
/// ```
/// {@endtemplate}
class AppCard extends StatelessWidget {
  /// {@macro app_card}
  const AppCard({
    required this.style,
    required this.title,
    required this.content,
    this.background,
    super.key,
  });

  /// The card's background and corner radius.
  final AppCardStyle style;

  /// Rendered at the top of the card using [TextTheme.titleMedium].
  final String title;

  /// Rendered at the bottom of the card, below [title].
  final Widget content;

  /// An optional widget painted edge to edge beneath [title] and [content].
  ///
  /// Unlike [AppCardStyle.background] this is laid out rather than painted,
  /// which makes it the slot for decorative children such as a corner icon.
  /// It ignores the card's padding, so align it yourself.
  final Widget? background;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      child: DecoratedBox(
        decoration: style.background,
        child: Stack(
          children: [
            if (background != null) Positioned.fill(child: background!),
            Padding(
              padding: EdgeInsets.all(context.appSpacing.lg),
              child: ForegroundColorOverride(
                color: style.foregroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) => Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    content,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
