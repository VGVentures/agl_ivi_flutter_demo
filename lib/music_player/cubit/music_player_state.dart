part of 'music_player_cubit.dart';

/// {@template music_player_state}
/// The current playback state of the [MusicPlayerCubit].
/// {@endtemplate}
class MusicPlayerState extends Equatable {
  /// {@macro music_player_state}
  const MusicPlayerState({
    this.trackIndex = 0,
    this.isPlaying = false,
    this.isShuffleEnabled = false,
    this.isLoopEnabled = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  /// The index of the current track within [playlist].
  final int trackIndex;

  /// Whether the current track is playing.
  final bool isPlaying;

  /// Whether [MusicPlayerCubit.skipToNext] picks a random track.
  final bool isShuffleEnabled;

  /// Whether the current track repeats when it finishes.
  final bool isLoopEnabled;

  /// The current playback position of the track.
  final Duration position;

  /// The duration of the current track.
  final Duration duration;

  /// The currently loaded track.
  Track get track => playlist[trackIndex];

  /// Returns a copy of this state with the given fields replaced.
  MusicPlayerState copyWith({
    int? trackIndex,
    bool? isPlaying,
    bool? isShuffleEnabled,
    bool? isLoopEnabled,
    Duration? position,
    Duration? duration,
  }) {
    return MusicPlayerState(
      trackIndex: trackIndex ?? this.trackIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isLoopEnabled: isLoopEnabled ?? this.isLoopEnabled,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  @override
  List<Object?> get props => [
    trackIndex,
    isPlaying,
    isShuffleEnabled,
    isLoopEnabled,
    position,
    duration,
  ];
}
