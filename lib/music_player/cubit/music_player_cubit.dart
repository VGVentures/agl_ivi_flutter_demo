import 'dart:async';
import 'dart:math';

import 'package:agl_ivi_vgv_demo/music_player/cubit/playlist.dart';
import 'package:agl_ivi_vgv_demo/music_player/cubit/track.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'music_player_state.dart';

/// {@template music_player_cubit}
/// Manages playback of the in-car [playlist] through an [AudioPlayer].
/// {@endtemplate}
class MusicPlayerCubit extends Cubit<MusicPlayerState> {
  /// {@macro music_player_cubit}
  MusicPlayerCubit({AudioPlayer? player})
    : _player = player ?? AudioPlayer(),
      super(MusicPlayerState(duration: playlist.first.duration)) {
    _positionSubscription = _player.onPositionChanged.listen(
      (position) => emit(state.copyWith(position: position)),
    );
    _durationSubscription = _player.onDurationChanged.listen(
      (duration) => emit(state.copyWith(duration: duration)),
    );
    _completeSubscription = _player.onPlayerComplete.listen(
      (_) => skipToNext(),
    );
    unawaited(_load(state.trackIndex, autoplay: false));
  }

  final AudioPlayer _player;
  final _random = Random();
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration> _durationSubscription;
  late final StreamSubscription<void> _completeSubscription;

  Future<void> _load(int index, {required bool autoplay}) async {
    final track = playlist[index];
    try {
      await _player.setSourceUrl(track.url);
    } on Object catch (error, stackTrace) {
      // Streaming the track failed (no network, no reachable host, no
      // codec/protocol support in the platform audio backend, ...). Logged
      // rather than surfaced in [MusicPlayerState] so a transient failure on
      // one track doesn't need new UI; the player just stays put on the
      // previous track, which is more informative than silently doing
      // nothing with no trace of why.
      // ignore: avoid_print
      print(
        '[MusicPlayerCubit] Failed to load "${track.title}" from '
        '${track.url}: $error\n$stackTrace',
      );
      return;
    }
    emit(
      state.copyWith(
        trackIndex: index,
        position: Duration.zero,
        duration: track.duration,
        isPlaying: autoplay,
      ),
    );
    if (autoplay) {
      try {
        await _player.resume();
      } on Object catch (error, stackTrace) {
        // print, not a logging package: guaranteed visible in `journalctl`
        // on the deployed target regardless of build mode or whether a
        // debugger/DevTools is attached (dart:developer.log is not).
        // ignore: avoid_print
        print(
          '[MusicPlayerCubit] Failed to resume "${track.title}": '
          '$error\n$stackTrace',
        );
        emit(state.copyWith(isPlaying: false));
      }
    }
  }

  /// Toggles between playing and pausing the current track.
  Future<void> togglePlayPause() async {
    try {
      if (state.isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
    } on Object catch (error, stackTrace) {
      // print, not a logging package: see the note in _load.
      // ignore: avoid_print
      print(
        '[MusicPlayerCubit] Failed to '
        '${state.isPlaying ? 'pause' : 'resume'} "${state.track.title}": '
        '$error\n$stackTrace',
      );
      return;
    }
    emit(state.copyWith(isPlaying: !state.isPlaying));
  }

  /// Skips to the next track, choosing randomly when shuffle is enabled.
  Future<void> skipToNext() async {
    final nextIndex = state.isShuffleEnabled
        ? _random.nextInt(playlist.length)
        : (state.trackIndex + 1) % playlist.length;
    await _load(nextIndex, autoplay: state.isPlaying);
  }

  /// Skips to the previous track.
  Future<void> skipToPrevious() async {
    final previousIndex =
        (state.trackIndex - 1 + playlist.length) % playlist.length;
    await _load(previousIndex, autoplay: state.isPlaying);
  }

  /// Plays the track at [index] in [playlist] from its start.
  ///
  /// Picking a track is an explicit request to hear it, so it starts
  /// playing even if the player was paused — unlike [skipToNext] and
  /// [skipToPrevious], which keep whatever the player was doing.
  Future<void> playTrackAt(int index) async {
    if (index < 0 || index >= playlist.length) return;
    await _load(index, autoplay: true);
  }

  /// Moves playback of the current track to [position].
  Future<void> seek(Duration position) async {
    final clamped = position < Duration.zero
        ? Duration.zero
        : (position > state.duration ? state.duration : position);
    try {
      await _player.seek(clamped);
    } on Object catch (error, stackTrace) {
      // print, not a logging package: see the note in _load.
      // ignore: avoid_print
      print(
        '[MusicPlayerCubit] Failed to seek "${state.track.title}" to '
        '$clamped: $error\n$stackTrace',
      );
      return;
    }
    // Emitted rather than waited on: the position stream only reports again
    // once playback advances, so a seek while paused would otherwise leave
    // the bar sitting where it was dragged from.
    emit(state.copyWith(position: clamped));
  }

  /// Toggles shuffle mode, randomizing the track chosen by [skipToNext].
  void toggleShuffle() =>
      emit(state.copyWith(isShuffleEnabled: !state.isShuffleEnabled));

  /// Toggles whether the current track repeats when it finishes.
  Future<void> toggleLoop() async {
    final isLoopEnabled = !state.isLoopEnabled;
    await _player.setReleaseMode(
      isLoopEnabled ? ReleaseMode.loop : ReleaseMode.release,
    );
    emit(state.copyWith(isLoopEnabled: isLoopEnabled));
  }

  @override
  Future<void> close() async {
    await _positionSubscription.cancel();
    await _durationSubscription.cancel();
    await _completeSubscription.cancel();
    await _player.dispose();
    return super.close();
  }
}
