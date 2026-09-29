import 'package:agl_ivi_vgv_demo/music_player/cubit/music_player_cubit.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Music card on the home grid: what is playing right now, and the
/// transport controls for it.
///
/// Reads the app-wide [MusicPlayerCubit] rather than creating one, so the
/// card and the overlay it opens drive the same audio player instead of
/// each starting playback of its own.
class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MusicPlayerCubit>();
    return BlocBuilder<MusicPlayerCubit, MusicPlayerState>(
      builder: (context, state) {
        return MusicPlayerCard(
          mediaType: 'MEDIA',
          mediaName: state.track.title,
          mediaAuthor: state.track.artist,
          mediaArt: AssetImage(state.track.artAsset),
          mediaPlayedProgress: state.position,
          mediaDuration: state.duration,
          isPlaying: state.isPlaying,
          isShuffleEnabled: state.isShuffleEnabled,
          isLoopEnabled: state.isLoopEnabled,
          onShufflePressed: cubit.toggleShuffle,
          onSkipToPreviousPressed: cubit.skipToPrevious,
          onPlayPausePressed: cubit.togglePlayPause,
          onSkipToNextPressed: cubit.skipToNext,
          onLoopPressed: cubit.toggleLoop,
        );
      },
    );
  }
}
