import 'package:equatable/equatable.dart';

/// {@template track}
/// A single playable song in the music player's playlist.
/// {@endtemplate}
class Track extends Equatable {
  /// {@macro track}
  const Track({
    required this.title,
    required this.artist,
    required this.url,
    required this.artAsset,
    required this.duration,
  });

  /// The song title.
  final String title;

  /// The performing artist.
  final String artist;

  /// The streaming URL of the audio file.
  final String url;

  /// The bundled asset path of the track's cover art. Bundled rather than
  /// streamed (unlike [url]) so it still shows without a network connection.
  final String artAsset;

  /// The song's known duration, used before playback reports the real one.
  final Duration duration;

  @override
  List<Object?> get props => [title, artist, url, artAsset, duration];
}
