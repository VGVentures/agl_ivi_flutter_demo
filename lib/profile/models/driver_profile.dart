import 'package:agl_ivi_vgv_demo/hvac/hvac.dart';
import 'package:agl_ivi_vgv_demo/phone/phone.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';

/// A driver the car knows, and everything it sets when they get in.
///
/// A fixed list rather than anything a driver builds: the point of the
/// panel is showing what one tap does to a whole head unit, and five
/// worked-out drivers say that better than an empty form. Each one carries
/// a setting from every corner of the app — the theme it is painted in, the
/// city it reports on, how it writes numbers and times, how the car drives,
/// which handset it is paired with and how the cabin is set — so no card on
/// the home screen is left out of the change.
///
/// The values are chosen to disagree with each other on purpose: two
/// profiles that differed only in name would make switching between them
/// look like nothing happened.
enum DriverProfile {
  jorge(
    name: 'Jorge Coca',
    tagline: 'Daily driver',
    avatarAsset: 'assets/avatars/jorge.svg',
    avatarBackground: Color(0xFFFED988),
    themeId: AppThemeId.rainbow,
    location: AppLocation.berlin,
    timeFormat: AppTimeFormat.twentyFourHour,
    unitSystem: AppUnitSystem.international,
    driveMode: DriveMode.eco,
    phone: ConnectedPhone.iPhone16Pro,
    climate: CabinClimate(temperature: 70, fanSpeed: 1, seatRecline: 1),
  ),
  sam(
    name: 'Sam Okafor',
    tagline: 'Weekend roads',
    avatarAsset: 'assets/avatars/sam.svg',
    avatarBackground: Color(0xFFFF9A8B),
    themeId: AppThemeId.rainbow,
    location: AppLocation.sanFrancisco,
    timeFormat: AppTimeFormat.twelveHour,
    unitSystem: AppUnitSystem.imperial,
    driveMode: DriveMode.sport,
    phone: ConnectedPhone.pixel9Pro,
    climate: CabinClimate(temperature: 65, fanSpeed: 3, isAcOn: true),
  ),
  mei(
    name: 'Mei Tanaka',
    tagline: 'City commute',
    avatarAsset: 'assets/avatars/mei.svg',
    avatarBackground: Color(0xFFF7B2D9),
    themeId: AppThemeId.earthy,
    location: AppLocation.tokyo,
    timeFormat: AppTimeFormat.twentyFourHour,
    unitSystem: AppUnitSystem.international,
    driveMode: DriveMode.comfort,
    phone: ConnectedPhone.galaxyS25Ultra,
    climate: CabinClimate(
      temperature: 72,
      fanSpeed: 2,
      seatRecline: 2,
      seatHeat: 1,
    ),
  ),
  lars(
    name: 'Lars Eriksen',
    tagline: 'Winter routes',
    avatarAsset: 'assets/avatars/lars.svg',
    avatarBackground: Color(0xFFA7D8F0),
    themeId: AppThemeId.earthy,
    location: AppLocation.newYork,
    timeFormat: AppTimeFormat.twelveHour,
    unitSystem: AppUnitSystem.imperial,
    driveMode: DriveMode.snow,
    phone: ConnectedPhone.iPhoneSe,
    climate: CabinClimate(temperature: 75, fanSpeed: 2, seatHeat: 3),
  ),
  guest(
    name: 'Guest',
    tagline: 'Borrowed the car',
    avatarAsset: 'assets/avatars/guest.svg',
    avatarBackground: Color(0xFFCFCFCF),
    themeId: AppThemeId.rainbow,
    location: AppLocation.berlin,
    timeFormat: AppTimeFormat.twentyFourHour,
    unitSystem: AppUnitSystem.international,
    driveMode: DriveMode.comfort,
    phone: ConnectedPhone.onePlus13,
    climate: CabinClimate(temperature: 69, fanSpeed: 1),
  );

  const DriverProfile({
    required this.name,
    required this.tagline,
    required this.avatarAsset,
    required this.avatarBackground,
    required this.themeId,
    required this.location,
    required this.timeFormat,
    required this.unitSystem,
    required this.driveMode,
    required this.phone,
    required this.climate,
  });

  /// The driver written out, as it reads on the card.
  final String name;

  /// What this driver uses the car for, which is what tells two profiles
  /// apart once their names have been read.
  final String tagline;

  /// The driver's portrait, as an SVG asset path.
  ///
  /// Drawn rather than photographed: a demo has no real drivers to
  /// photograph, and an illustrated set can be given the same crop,
  /// lighting and framing, which a handful of stock photographs never
  /// have.
  final String avatarAsset;

  /// The circle the portrait is drawn on, and the profile's accent
  /// throughout the panel.
  final Color avatarBackground;

  /// The theme the whole app is painted in.
  final AppThemeId themeId;

  /// The city the weather, the clock and the map report on.
  final AppLocation location;

  /// How every clock in the app writes the time.
  final AppTimeFormat timeFormat;

  /// The units measurements are reported in.
  final AppUnitSystem unitSystem;

  /// How the car drives.
  final DriveMode driveMode;

  /// The handset the head unit pairs with.
  final ConnectedPhone phone;

  /// How the driver's side of the cabin is set.
  final CabinClimate climate;
}
