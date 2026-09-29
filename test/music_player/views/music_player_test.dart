import 'package:agl_ivi_vgv_demo/music_player/music_player.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMusicPlayerCubit extends MockCubit<MusicPlayerState>
    implements MusicPlayerCubit {}

void main() {
  group('MusicPlayer', () {
    late MusicPlayerCubit cubit;

    setUp(() {
      cubit = _MockMusicPlayerCubit();
      when(() => cubit.toggleShuffle()).thenReturn(null);
      when(() => cubit.toggleLoop()).thenAnswer((_) async {});
    });

    Widget subject(MusicPlayerState state) {
      when(() => cubit.state).thenReturn(state);
      return BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: AppTheme.rainbow,
          home: const Scaffold(
            body: Center(
              child: SizedBox(width: 460, height: 380, child: MusicPlayer()),
            ),
          ),
        ),
      );
    }

    /// The fill behind a control, which is what says whether it is on.
    Color? fillOf(WidgetTester tester, String tooltip) {
      final button = tester.widget<IconButton>(
        find.descendant(
          of: find.byTooltip(tooltip),
          matching: find.byType(IconButton),
        ),
      );
      return button.style?.backgroundColor?.resolve({});
    }

    testWidgets('shuffle and repeat sit unfilled while they are off', (
      tester,
    ) async {
      await tester.pumpWidget(subject(const MusicPlayerState()));
      await tester.pumpAndSettle();

      expect(fillOf(tester, 'Shuffle'), Colors.transparent);
      expect(fillOf(tester, 'Repeat'), Colors.transparent);
    });

    testWidgets('shuffle fills with the accent once it is on', (tester) async {
      final accent = AppTheme.rainbow
          .extension<MusicPlayerStyleCard>()!
          .accentColor;

      await tester.pumpWidget(
        subject(const MusicPlayerState(isShuffleEnabled: true)),
      );
      await tester.pumpAndSettle();

      expect(fillOf(tester, 'Shuffle'), accent);
      expect(fillOf(tester, 'Repeat'), Colors.transparent);
    });

    testWidgets('repeat fills with the accent once it is on', (tester) async {
      final accent = AppTheme.rainbow
          .extension<MusicPlayerStyleCard>()!
          .accentColor;

      await tester.pumpWidget(
        subject(const MusicPlayerState(isLoopEnabled: true)),
      );
      await tester.pumpAndSettle();

      expect(fillOf(tester, 'Repeat'), accent);
      expect(fillOf(tester, 'Shuffle'), Colors.transparent);
    });

    testWidgets('tapping shuffle and repeat asks the player to toggle them', (
      tester,
    ) async {
      await tester.pumpWidget(subject(const MusicPlayerState()));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Shuffle'));
      await tester.tap(find.byTooltip('Repeat'));
      await tester.pump();

      verify(() => cubit.toggleShuffle()).called(1);
      verify(() => cubit.toggleLoop()).called(1);
    });
  });
}
