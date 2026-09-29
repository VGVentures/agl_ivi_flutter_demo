import 'package:agl_ivi_vgv_demo/boost/views/boost.dart';
import 'package:agl_ivi_vgv_demo/calendar/calendar.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ivi_vgv_demo/ev_range/ev_range.dart';
import 'package:agl_ivi_vgv_demo/home/views/card_overlay_target.dart';
import 'package:agl_ivi_vgv_demo/home/views/main_stage.dart';
import 'package:agl_ivi_vgv_demo/music_player/music_player.dart';
import 'package:agl_ivi_vgv_demo/phone/phone.dart';
import 'package:agl_ivi_vgv_demo/powertrain/powertrain.dart';
import 'package:agl_ivi_vgv_demo/profile/profile.dart';
import 'package:agl_ivi_vgv_demo/trip_efficiency/views/trip_efficiency.dart';
import 'package:agl_ivi_vgv_demo/weather/weather.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppGrid(
      columns: 5,
      rows: 7,
      spacing: context.appSpacing.xs,
      items: [
        AppGridItem(
          child: CardOverlayTarget(
            background: context.appCardTheme.calendar.background,
            overlayBackground: context.appCardTheme.calendar.overlaySurface,
            borderRadius: context.appCardTheme.calendar.borderRadius,
            heroTag: 'calendar-card',
            contentBuilder: (_) => const CalendarOverlay(),
            child: const CalendarTile(),
          ),
          column: 0,
          row: 0,
          rowSpan: 2,
        ),
        AppGridItem(
          child: CardOverlayTarget(
            background: context.appCardTheme.weather.background,
            overlayBackground: context.appCardTheme.weather.overlaySurface,
            borderRadius: context.appCardTheme.weather.borderRadius,
            heroTag: 'weather-card',
            contentBuilder: (_) => const WeatherOverlay(),
            child: const WeatherTile(),
          ),
          column: 1,
          row: 0,
          rowSpan: 2,
        ),
        AppGridItem(
          child: CardOverlayTarget(
            background: BoxDecoration(
              color: context.tripEfficiencyCardStyle.backgroundColor,
            ),
            overlayBackground: BoxDecoration(
              color: context.tripEfficiencyCardStyle.overlaySurfaceColor,
            ),
            borderRadius: context.tripEfficiencyCardStyle.borderRadius,
            heroTag: 'trip-card',
            // The three cards in the stack share one slot and one tap, so
            // they share one panel: see `PowertrainOverlay`.
            contentBuilder: (_) => const PowertrainOverlay(),
            child: const VerticalScrollableStackCard(
              children: [
                TripEfficiency(),
                EvRange(),
                Boost(),
              ],
            ),
          ),
          column: 2,
          row: 0,
          rowSpan: 2,
        ),
        AppGridItem(
          child: Builder(
            builder: (context) {
              // The card is repainted by whichever mode is selected, so the
              // decoration its overlay grows out of has to be read from the
              // mode in force rather than fixed for the card.
              final mode = context.select<DriveModeCubit, DriveMode>(
                (cubit) => cubit.state.mode,
              );
              final style = context.driveModeStyleCard.styleFor(mode);
              return CardOverlayTarget(
                background: style.background,
                overlayBackground: style.overlaySurface,
                borderRadius: style.borderRadius,
                heroTag: 'drive-mode-card',
                contentBuilder: (_) => const DriveModeOverlay(),
                child: const DriveModeTile(),
              );
            },
          ),
          column: 3,
          row: 0,
          columnSpan: 2,
          rowSpan: 2,
        ),
        const AppGridItem(
          child: MainStage(),
          column: 0,
          row: 2,
          columnSpan: 3,
          rowSpan: 5,
        ),
        AppGridItem(
          child: CardOverlayTarget(
            background: BoxDecoration(
              color: context.musicPlayerStyleCard.backgroundColor,
            ),
            borderRadius: context.musicPlayerStyleCard.borderRadius,
            heroTag: 'music-player-card',
            contentBuilder: (_) => const MusicPlayerOverlay(),
            child: const MusicPlayer(),
          ),
          column: 3,
          row: 2,
          columnSpan: 2,
          rowSpan: 3,
        ),
        AppGridItem(
          child: CardOverlayTarget(
            background: BoxDecoration(
              color: context.phoneStyleCard.backgroundColor,
            ),
            borderRadius: context.phoneStyleCard.borderRadius,
            heroTag: 'phone-card',
            contentBuilder: (_) => const PhoneOverlay(),
            child: const Phone(),
          ),
          column: 3,
          row: 5,
          columnSpan: 2,
        ),
        AppGridItem(
          child: CardOverlayTarget(
            background: BoxDecoration(
              color: context.profileStyleCard.backgroundColor,
            ),
            borderRadius: context.profileStyleCard.borderRadius,
            heroTag: 'profile-card',
            contentBuilder: (_) => const ProfileOverlay(),
            child: const Profile(),
          ),
          column: 3,
          row: 6,
          columnSpan: 2,
        ),
      ],
    );
  }
}
