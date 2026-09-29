import 'package:agl_ui/agl_ui.dart';

/// The handsets the head unit knows how to pair with.
///
/// A fixed list rather than anything discovered: nothing in the demo talks
/// to Bluetooth, and the point of the panel is showing what connecting an
/// Android instead of an iPhone does to the car's own screens. The phones
/// are chosen to cover both projection systems and both ways of connecting,
/// so every combination the card can land in is reachable from the list.
enum ConnectedPhone {
  iPhone16Pro(
    name: 'iPhone 16 Pro',
    os: 'iOS 26.1',
    projection: PhoneProjection.carPlay,
    isWireless: true,
  ),
  iPhoneSe(
    name: 'iPhone SE',
    os: 'iOS 26.1',
    projection: PhoneProjection.carPlay,
    isWireless: false,
  ),
  pixel9Pro(
    name: 'Pixel 9 Pro',
    os: 'Android 16',
    projection: PhoneProjection.androidAuto,
    isWireless: true,
  ),
  galaxyS25Ultra(
    name: 'Galaxy S25 Ultra',
    os: 'Android 16',
    projection: PhoneProjection.androidAuto,
    isWireless: true,
  ),
  onePlus13(
    name: 'OnePlus 13',
    os: 'Android 16',
    projection: PhoneProjection.androidAuto,
    isWireless: false,
  );

  const ConnectedPhone({
    required this.name,
    required this.os,
    required this.projection,
    required this.isWireless,
  });

  /// The handset written out, as it reads on the card.
  final String name;

  /// What it is running, which is what tells two iPhones apart in a list
  /// once their names have been read.
  final String os;

  /// What it hands the head unit once it is connected.
  final PhoneProjection projection;

  /// Whether it projects over the air or needs a cable.
  final bool isWireless;

  /// How it is connected, written out.
  String get connectionLabel => isWireless ? 'Wireless' : 'USB';
}
