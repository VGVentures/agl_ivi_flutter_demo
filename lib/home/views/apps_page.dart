import 'package:agl_ivi_vgv_demo/calendar/calendar.dart';
import 'package:agl_ivi_vgv_demo/home/views/card_overlay_target.dart';
import 'package:agl_ivi_vgv_demo/music_player/music_player.dart';
import 'package:agl_ivi_vgv_demo/weather/weather.dart';
import 'package:agl_ui/agl_ui.dart';

/// The app launcher, shown in place of the home screen's cards.
///
/// The home button in the permanent controls strip flips between the two.
/// Only the cards are replaced: the strip itself — the HVAC controls on
/// either side of that button — sits outside `HomeNavigator`, so it stays
/// visible and usable whichever of the two is showing.
///
/// Each tile opens the same overlay the app's card opens on the home
/// screen, through the same [CardOverlayTarget], so an app looks and
/// behaves the same however the driver reached it.
class AppsPage extends StatelessWidget {
  const AppsPage({super.key});

  /// The side of one launcher tile.
  ///
  /// Fixed rather than divided out of the page, so the grid stays a grid of
  /// app icons as apps are added instead of the icons shrinking to fit.
  static const _tileSize = 240.0;

  @override
  Widget build(BuildContext context) {
    final calendar = context.appCardTheme.calendar;
    final weather = context.appCardTheme.weather;
    final music = context.musicPlayerStyleCard;
    final musicBackground = BoxDecoration(color: music.backgroundColor);

    return Padding(
      padding: EdgeInsets.all(context.appSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Apps', style: Theme.of(context).textTheme.displayMedium),
          SizedBox(height: context.appSpacing.lg),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: context.appSpacing.lg,
                runSpacing: context.appSpacing.lg,
                children: [
                  _AppTile(
                    icon: AppIcons.calendar,
                    label: 'Calendar',
                    heroTag: 'apps-calendar',
                    style: calendar,
                    contentBuilder: (_) => const CalendarOverlay(),
                  ),
                  _AppTile(
                    icon: AppIcons.weatherPartlyCloudy,
                    label: 'Weather',
                    heroTag: 'apps-weather',
                    style: weather,
                    contentBuilder: (_) => const WeatherOverlay(),
                  ),
                  _AppTile(
                    icon: AppIcons.musicNote,
                    label: 'Music',
                    heroTag: 'apps-music',
                    style: AppCardStyle(
                      background: musicBackground,
                      borderRadius: music.borderRadius,
                    ),
                    contentBuilder: (_) => const MusicPlayerOverlay(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One app on [AppsPage], sized to the launcher's grid and wired to the
/// overlay it opens.
class _AppTile extends StatelessWidget {
  const _AppTile({
    required this.icon,
    required this.label,
    required this.heroTag,
    required this.style,
    required this.contentBuilder,
  });

  final AppIconData icon;
  final String label;

  /// Its own tag rather than the one the app's home screen card uses: the
  /// dashboard is still in the tree while the launcher crossfades in, and
  /// two live Heroes cannot share a tag.
  final Object heroTag;

  /// The app's card style, so the tile is painted in the app's own color
  /// and its overlay settles on the same surface the card's does.
  final AppCardStyle style;

  final WidgetBuilder contentBuilder;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: AppsPage._tileSize,
      child: CardOverlayTarget(
        background: style.background,
        overlayBackground: style.overlaySurface,
        borderRadius: style.borderRadius,
        heroTag: heroTag,
        contentBuilder: contentBuilder,
        child: AppLauncherCard(
          icon: icon,
          label: label,
          background: style.background,
          borderRadius: style.borderRadius,
        ),
      ),
    );
  }
}
