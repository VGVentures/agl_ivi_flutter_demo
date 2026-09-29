import 'package:agl_ivi_vgv_demo/music_player/music_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAudioPlayer extends Mock implements AudioPlayer {}

/// What the cubit settles on once the load it starts on creation lands.
///
/// Identical to the initial state — the first track, paused, at its known
/// length — but still reported, since a cubit always publishes its first
/// emission. Every expectation below starts with it.
final _loaded = MusicPlayerState(duration: playlist.first.duration);

void main() {
  group('MusicPlayerCubit', () {
    late AudioPlayer player;

    setUpAll(() {
      registerFallbackValue(Duration.zero);
      registerFallbackValue(ReleaseMode.release);
    });

    setUp(() {
      player = _MockAudioPlayer();
      when(() => player.onPositionChanged).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => player.onDurationChanged).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => player.onPlayerComplete).thenAnswer(
        (_) => const Stream.empty(),
      );
      when(() => player.setSourceUrl(any())).thenAnswer((_) async {});
      when(() => player.resume()).thenAnswer((_) async {});
      when(() => player.pause()).thenAnswer((_) async {});
      when(() => player.seek(any())).thenAnswer((_) async {});
      when(() => player.setReleaseMode(any())).thenAnswer((_) async {});
      when(() => player.dispose()).thenAnswer((_) async {});
    });

    MusicPlayerCubit build() => MusicPlayerCubit(player: player);

    test('starts on the first track, paused', () {
      final cubit = build();
      expect(cubit.state.trackIndex, 0);
      expect(cubit.state.isPlaying, isFalse);
      expect(cubit.state.track, playlist.first);
      expect(cubit.state.duration, playlist.first.duration);
    });

    group('playTrackAt', () {
      blocTest<MusicPlayerCubit, MusicPlayerState>(
        'loads the picked track and plays it from the start',
        build: build,
        act: (cubit) => cubit.playTrackAt(3),
        expect: () => [
          _loaded,
          MusicPlayerState(
            trackIndex: 3,
            isPlaying: true,
            duration: playlist[3].duration,
          ),
        ],
        verify: (_) {
          verify(() => player.setSourceUrl(playlist[3].url)).called(1);
          verify(() => player.resume()).called(1);
        },
      );

      blocTest<MusicPlayerCubit, MusicPlayerState>(
        'ignores an index outside the playlist',
        build: build,
        act: (cubit) => cubit.playTrackAt(playlist.length),
        expect: () => [_loaded],
        verify: (_) {
          // Only the load the cubit does on creation.
          verify(() => player.setSourceUrl(any())).called(1);
        },
      );
    });

    group('seek', () {
      blocTest<MusicPlayerCubit, MusicPlayerState>(
        'moves playback to the requested position',
        build: build,
        act: (cubit) => cubit.seek(const Duration(minutes: 1)),
        expect: () => [
          _loaded,
          MusicPlayerState(
            position: const Duration(minutes: 1),
            duration: playlist.first.duration,
          ),
        ],
        verify: (_) {
          verify(() => player.seek(const Duration(minutes: 1))).called(1);
        },
      );

      blocTest<MusicPlayerCubit, MusicPlayerState>(
        'clamps a position past the end of the track',
        build: build,
        act: (cubit) => cubit.seek(const Duration(hours: 1)),
        expect: () => [
          _loaded,
          MusicPlayerState(
            position: playlist.first.duration,
            duration: playlist.first.duration,
          ),
        ],
        verify: (_) {
          verify(() => player.seek(playlist.first.duration)).called(1);
        },
      );

      blocTest<MusicPlayerCubit, MusicPlayerState>(
        'leaves the position alone when the player refuses to seek',
        build: () {
          when(() => player.seek(any())).thenThrow(Exception('no source'));
          return build();
        },
        act: (cubit) => cubit.seek(const Duration(seconds: 30)),
        expect: () => [_loaded],
      );
    });

    blocTest<MusicPlayerCubit, MusicPlayerState>(
      'skipToPrevious wraps around to the end of the playlist',
      build: build,
      act: (cubit) => cubit.skipToPrevious(),
      expect: () => [
        _loaded,
        MusicPlayerState(
          trackIndex: playlist.length - 1,
          duration: playlist.last.duration,
        ),
      ],
    );
  });
}
