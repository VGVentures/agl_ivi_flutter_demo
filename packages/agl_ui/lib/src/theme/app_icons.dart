import 'package:agl_ui/agl_ui.dart';

/// {@template app_icon_data}
/// Describes a single icon exposed by `agl_ui` (see [AppIcons]), hiding from
/// callers whether it is backed by an SVG asset or a Material [IconData].
///
/// Render it with [AppIcon].
/// {@endtemplate}
sealed class AppIconData {
  const AppIconData();

  /// An icon backed by an SVG asset bundled with `agl_ui`.
  const factory AppIconData.svg(String assetName) = _SvgIconData;

  /// An icon backed by a Material [IconData].
  const factory AppIconData.material(IconData iconData) = _MaterialIconData;

  /// Builds the underlying icon widget. [size] and [color] are resolved by
  /// [AppIcon] from the ambient [IconTheme] when not overridden.
  Widget build({double? size, Color? color});
}

final class _SvgIconData extends AppIconData {
  const _SvgIconData(this.assetName);

  final String assetName;

  @override
  Widget build({double? size, Color? color}) {
    return SvgPicture.asset(
      assetName,
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}

final class _MaterialIconData extends AppIconData {
  const _MaterialIconData(this.iconData);

  final IconData iconData;

  @override
  Widget build({double? size, Color? color}) {
    return Icon(iconData, size: size, color: color);
  }
}

/// Compile-time safe [AppIconData] values for the icons bundled with
/// `agl_ui`. Render them with [AppIcon].
abstract final class AppIcons {
  static const AppIconData acUnit = AppIconData.material(Icons.ac_unit);
  static const AppIconData boostGauge = AppIconData.svg(
    'packages/agl_ui/assets/boost_gauge.svg',
  );
  static const AppIconData ecoPlant = AppIconData.svg(
    'packages/agl_ui/assets/eco_plant.svg',
  );
  static const AppIconData fan = AppIconData.svg(
    'packages/agl_ui/assets/fan.svg',
  );
  static const AppIconData acSnowflake24 = AppIconData.svg(
    'packages/agl_ui/assets/icon_ac_snowflake_24.svg',
  );
  static const AppIconData acSnowflake32 = AppIconData.svg(
    'packages/agl_ui/assets/icon_ac_snowflake_32.svg',
  );
  static const AppIconData airflowDirection = AppIconData.svg(
    'packages/agl_ui/assets/icon_airflow_direction.svg',
  );
  // The two phone projection systems, drawn as a pair: the same weight and
  // the same optical size, so neither reads as the more official of the
  // two on a card that swaps one for the other. Both are approximations of
  // the marks they stand for, not the trademarked artwork.
  static const AppIconData androidAuto = AppIconData.svg(
    'packages/agl_ui/assets/icon_android_auto.svg',
  );
  static const AppIconData carPlay = AppIconData.svg(
    'packages/agl_ui/assets/icon_carplay.svg',
  );
  static const AppIconData batteryHalf = AppIconData.svg(
    'packages/agl_ui/assets/icon_battery_half.svg',
  );
  static const AppIconData climateSync = AppIconData.svg(
    'packages/agl_ui/assets/icon_climate_sync.svg',
  );
  // The three settings a driver picks rather than drives: what the app is
  // painted in, how it writes times, and what scale it measures on.
  static const AppIconData palette = AppIconData.material(
    Icons.palette_outlined,
  );
  static const AppIconData clock = AppIconData.material(
    Icons.schedule_outlined,
  );
  static const AppIconData ruler = AppIconData.material(Icons.straighten);
  // The drive modes, drawn as a family: one glyph each, used on the mode
  // list and beside the active mode's name. The washed-in outlines the
  // cards themselves are backed with are a different language and live on
  // [DriveMode.watermarkAsset] instead.
  static const AppIconData driveComfort = AppIconData.material(Icons.waves);
  static const AppIconData driveCustom = AppIconData.material(Icons.tune);
  static const AppIconData driveEco = AppIconData.material(
    Icons.eco_outlined,
  );
  static const AppIconData driveSnow = AppIconData.material(Icons.ac_unit);
  static const AppIconData driveSport = AppIconData.material(
    Icons.speed_outlined,
  );
  static const AppIconData iconFan = AppIconData.svg(
    'packages/agl_ui/assets/icon_fan.svg',
  );
  static const AppIconData home = AppIconData.svg(
    'packages/agl_ui/assets/icon_home.svg',
  );
  // The apps the launcher lists, plus the grid the home button swaps to
  // while the home screen is the one showing. Drawn from Material rather
  // than the bundled set: they name an app rather than a vehicle function,
  // and the glyphs everyone already reads as "calendar" and "music" carry
  // that better than a house style would.
  static const AppIconData apps = AppIconData.material(Icons.grid_view_rounded);
  static const AppIconData calendar = AppIconData.material(
    Icons.calendar_month_outlined,
  );
  static const AppIconData musicNote = AppIconData.material(Icons.music_note);
  static const AppIconData map = AppIconData.material(Icons.map_outlined);
  static const AppIconData mediaRepeat = AppIconData.svg(
    'packages/agl_ui/assets/icon_media_repeat.svg',
  );
  static const AppIconData navTurnLeft = AppIconData.svg(
    'packages/agl_ui/assets/icon_nav_turn_left.svg',
  );
  static const AppIconData pause = AppIconData.svg(
    'packages/agl_ui/assets/icon_pause.svg',
  );
  static const AppIconData play = AppIconData.svg(
    'packages/agl_ui/assets/icon_play.svg',
  );
  static const AppIconData seatHeat = AppIconData.svg(
    'packages/agl_ui/assets/icon_seat_heat.svg',
  );
  static const AppIconData settingsSliders = AppIconData.svg(
    'packages/agl_ui/assets/icon_settings_sliders.svg',
  );
  static const AppIconData shuffle = AppIconData.svg(
    'packages/agl_ui/assets/icon_shuffle.svg',
  );
  static const AppIconData skipBack = AppIconData.svg(
    'packages/agl_ui/assets/icon_skip_back.svg',
  );
  static const AppIconData skipForward = AppIconData.svg(
    'packages/agl_ui/assets/icon_skip_forward.svg',
  );
  static const AppIconData vehicle = AppIconData.material(
    Icons.directions_car_outlined,
  );
  static const AppIconData waveform = AppIconData.svg(
    'packages/agl_ui/assets/icon_waveform.svg',
  );
  static const AppIconData mediaPause = AppIconData.svg(
    'packages/agl_ui/assets/media_pause.svg',
  );
  static const AppIconData mediaPlay = AppIconData.svg(
    'packages/agl_ui/assets/media_play.svg',
  );
  static const AppIconData mediaRepeatAlt = AppIconData.svg(
    'packages/agl_ui/assets/media_repeat.svg',
  );
  static const AppIconData mediaShuffle = AppIconData.svg(
    'packages/agl_ui/assets/media_shuffle.svg',
  );
  static const AppIconData mediaSkipNext = AppIconData.svg(
    'packages/agl_ui/assets/media_skip_next.svg',
  );
  static const AppIconData mediaSkipPrevious = AppIconData.svg(
    'packages/agl_ui/assets/media_skip_previous.svg',
  );
  static const AppIconData seatRecline = AppIconData.svg(
    'packages/agl_ui/assets/seat_recline.svg',
  );
  static const AppIconData sunDotted = AppIconData.svg(
    'packages/agl_ui/assets/sun_dotted.svg',
  );
  static const AppIconData sunrise = AppIconData.material(Icons.wb_twilight);
  static const AppIconData sunset = AppIconData.material(
    Icons.nightlight_round,
  );
  static const AppIconData waterDrop = AppIconData.material(
    Icons.water_drop_outlined,
  );
  static const AppIconData wind = AppIconData.material(Icons.air);
  static const AppIconData weatherClear = AppIconData.svg(
    'packages/agl_ui/assets/weather_clear.svg',
  );
  static const AppIconData weatherCloudy = AppIconData.svg(
    'packages/agl_ui/assets/weather_cloudy.svg',
  );
  static const AppIconData weatherDrizzle = AppIconData.svg(
    'packages/agl_ui/assets/weather_drizzle.svg',
  );
  static const AppIconData weatherFoggy = AppIconData.svg(
    'packages/agl_ui/assets/weather_foggy.svg',
  );
  static const AppIconData weatherPartlyCloudy = AppIconData.svg(
    'packages/agl_ui/assets/weather_partly_cloudy.svg',
  );
  static const AppIconData weatherRainy = AppIconData.svg(
    'packages/agl_ui/assets/weather_rainy.svg',
  );
  static const AppIconData weatherSnowy = AppIconData.svg(
    'packages/agl_ui/assets/weather_snowy.svg',
  );
  static const AppIconData weatherStormy = AppIconData.svg(
    'packages/agl_ui/assets/weather_stormy.svg',
  );
}
