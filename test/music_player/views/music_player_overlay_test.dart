import 'package:agl_ivi_vgv_demo/music_player/music_player.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMusicPlayerCubit extends MockCubit<MusicPlayerState>
    implements MusicPlayerCubit {}

void main() {
  group('MusicPlayerOverlay', () {
    late MusicPlayerCubit cubit;

    setUpAll(() => registerFallbackValue(Duration.zero));

    setUp(() {
      cubit = _MockMusicPlayerCubit();
      when(() => cubit.playTrackAt(any())).thenAnswer((_) async {});
      when(() => cubit.togglePlayPause()).thenAnswer((_) async {});
      when(() => cubit.seek(any())).thenAnswer((_) async {});
    });

    Widget subject({MusicPlayerState? state}) {
      when(() => cubit.state).thenReturn(state ?? const MusicPlayerState());
      return BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.rainbow,
          home: const Scaffold(body: MusicPlayerOverlay()),
        ),
      );
    }

    void sizeToHeadUnit(WidgetTester tester) {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
    }

    testWidgets('shows the playing track beside the whole playlist', (
      tester,
    ) async {
      sizeToHeadUnit(tester);

      await tester.pumpWidget(
        subject(
          state: MusicPlayerState(
            isPlaying: true,
            position: const Duration(seconds: 42),
            duration: playlist.first.duration,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NowPlayingPanel), findsOneWidget);
      expect(find.text('NOW PLAYING'), findsOneWidget);
      expect(find.text('UP NEXT'), findsOneWidget);
      expect(find.text('${playlist.length} TRACKS · 36 MIN'), findsOneWidget);
      // The playing track's title is on the player and on its own row.
      expect(find.text(playlist.first.title), findsNWidgets(2));
      expect(find.text('00:42'), findsOneWidget);
      expect(find.text(playlist[1].title), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('picking a track in the playlist plays it', (tester) async {
      sizeToHeadUnit(tester);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      await tester.tap(find.text(playlist[2].title));
      await tester.pump();

      verify(() => cubit.playTrackAt(2)).called(1);
    });

    testWidgets('tapping the playing track pauses instead of restarting it', (
      tester,
    ) async {
      sizeToHeadUnit(tester);

      await tester.pumpWidget(subject(state: const MusicPlayerState()));
      await tester.pumpAndSettle();

      // The row, not the player's own copy of the title.
      await tester.tap(find.byType(PlaylistTrackTile).first);
      await tester.pump();

      verify(() => cubit.togglePlayPause()).called(1);
      verifyNever(() => cubit.playTrackAt(any()));
    });

    testWidgets('dragging the progress bar seeks the track', (tester) async {
      sizeToHeadUnit(tester);

      await tester.pumpWidget(
        subject(
          state: MusicPlayerState(duration: playlist.first.duration),
        ),
      );
      await tester.pumpAndSettle();

      final bar = tester.getRect(find.byType(Slider));
      await tester.dragFrom(
        bar.centerLeft + const Offset(4, 0),
        Offset(bar.width / 2, 0),
      );
      await tester.pumpAndSettle();

      final seeked = verify(() => cubit.seek(captureAny())).captured.single;
      expect(seeked, isA<Duration>());
      expect((seeked as Duration).inSeconds, greaterThan(0));
    });

    testWidgets('holds together at the size it grows out of', (tester) async {
      // The panel is laid out at the tapped card's own size while the Hero
      // flight is still running, so the layout has to survive being a
      // fraction of its final width.
      tester.view.physicalSize = const Size(300, 240);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
