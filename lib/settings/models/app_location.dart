import 'package:latlong2/latlong.dart';
import 'package:timezone/timezone.dart' as tz;

/// The city the app is currently set to.
///
/// One selection drives three cards: the weather is fetched at
/// [coordinates], the calendar reads its clock in [timeZone], and the map
/// parks the vehicle at [coordinates].
enum AppLocation {
  berlin(
    label: 'BERLIN',
    latitude: 52.520008,
    longitude: 13.404954,
    timeZone: 'Europe/Berlin',
  ),
  newYork(
    label: 'NEW YORK',
    latitude: 40.712776,
    longitude: -74.005974,
    timeZone: 'America/New_York',
  ),
  sanFrancisco(
    label: 'SAN FRANCISCO',
    latitude: 37.774929,
    longitude: -122.419418,
    timeZone: 'America/Los_Angeles',
  ),
  tokyo(
    label: 'TOKYO',
    latitude: 35.689487,
    longitude: 139.691711,
    timeZone: 'Asia/Tokyo',
  );

  const AppLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.timeZone,
  });

  /// The name shown on the weather card and in the settings picker.
  final String label;

  final double latitude;

  final double longitude;

  /// The city's IANA time zone name, e.g. `Europe/Berlin`.
  ///
  /// Resolved through the tz database rather than stored as a fixed offset,
  /// so the clock stays right across daylight saving changes.
  final String timeZone;

  /// Where the map frames the vehicle.
  LatLng get coordinates => LatLng(latitude, longitude);

  /// [instant] read on this city's wall clock.
  ///
  /// The returned [DateTime] is a `TZDateTime`, so formatting it or pulling
  /// a `TimeOfDay` out of it gives the local time here rather than the head
  /// unit's own.
  DateTime localTime(DateTime instant) =>
      tz.TZDateTime.from(instant, tz.getLocation(timeZone));
}
