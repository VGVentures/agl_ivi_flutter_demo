import 'package:agl_ivi_vgv_demo/music_player/cubit/music_player_cubit.dart';
import 'package:agl_ivi_vgv_demo/music_player/cubit/playlist.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Music card's overlay: the full player on the leading side, and the
/// playlist it is working through beside it.
///
/// Drives the same [MusicPlayerCubit] the card does — provided above
/// `HomeNavigator` — so opening the panel takes over a track already
/// playing rather than starting it again, and anything done here is still
/// true on the card once the panel closes.
class MusicPlayerOverlay extends StatelessWidget {
  const MusicPlayerOverlay({super.key});

  /// Clears the close button [CardOverlayScaffold] paints over the
  /// content's top-left corner.
  static const _closeButtonClearance = 80.0;

  /// The smallest the two columns still read at — set by the five
  /// transport controls, which are sized for a driver's thumb and do not
  /// shrink. See [MinimumContentSize].
  static const _minimumContentSize = Size(900, 470);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerCubit, MusicPlayerState>(
      builder: (context, state) {
        final cubit = context.read<MusicPlayerCubit>();
        return Padding(
          padding: EdgeInsets.fromLTRB(
            context.appSpacing.xlg,
            _closeButtonClearance,
            context.appSpacing.xlg,
            context.appSpacing.lg,
          ),
          child: MinimumContentSize(
            size: _minimumContentSize,
            child: Row(
              // Both columns are given the panel's full height, so the
              // artwork and the list each fill their own side.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Proportional rather than fixed widths, so the two
                // columns keep their balance at every panel size.
                Flexible(
                  flex: 4,
                  child: NowPlayingPanel(
                    sourceLabel: 'NOW PLAYING',
                    title: state.track.title,
                    artist: state.track.artist,
                    art: AssetImage(state.track.artAsset),
                    position: state.position,
                    duration: state.duration,
                    isPlaying: state.isPlaying,
                    isShuffleEnabled: state.isShuffleEnabled,
                    isLoopEnabled: state.isLoopEnabled,
                    onSeek: cubit.seek,
                    onShufflePressed: cubit.toggleShuffle,
                    onSkipToPreviousPressed: cubit.skipToPrevious,
                    onPlayPausePressed: cubit.togglePlayPause,
                    onSkipToNextPressed: cubit.skipToNext,
                    onLoopPressed: cubit.toggleLoop,
                  ),
                ),
                SizedBox(width: context.appSpacing.xlg),
                Flexible(
                  flex: 5,
                  child: _Playlist(
                    trackIndex: state.trackIndex,
                    isPlaying: state.isPlaying,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The queue beside the player: every track in [playlist], the playing one
/// marked, each tappable to jump straight to it.
class _Playlist extends StatefulWidget {
  const _Playlist({required this.trackIndex, required this.isPlaying});

  /// The index of the track the player is loaded with.
  final int trackIndex;

  /// Whether that track is playing.
  final bool isPlaying;

  @override
  State<_Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<_Playlist> {
  final _controller = ScrollController();

  /// How tall one row is, used to scroll the playing track into view.
  /// Measured rather than imposed would mean laying the list out twice;
  /// the rows are a fixed shape, so this is what they come to.
  static const _rowExtent = 76.0;

  @override
  void initState() {
    super.initState();
    // The panel can open on a track well down a ten-track list, and the
    // point of showing the playlist is seeing where in it you are.
    WidgetsBinding.instance.addPostFrameCallback((_) => _revealCurrent());
  }

  @override
  void didUpdateWidget(_Playlist oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackIndex != widget.trackIndex) _revealCurrent();
  }

  /// Brings the playing track into view, without moving the list when it is
  /// already showing — so skipping through tracks near the top does not
  /// scroll under the driver's finger.
  void _revealCurrent() {
    if (!_controller.hasClients) return;
    final offset = widget.trackIndex * _rowExtent;
    final viewport = _controller.position.viewportDimension;
    final top = _controller.offset;
    if (offset >= top && offset + _rowExtent <= top + viewport) return;
    _controller.animateTo(
      offset.clamp(
        _controller.position.minScrollExtent,
        _controller.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final cubit = context.read<MusicPlayerCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'UP NEXT',
              style: textTheme.labelMedium?.copyWith(
                color: context.musicPlayerStyleCard.accentColor,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: context.appSpacing.sm),
            Text(
              '${playlist.length} TRACKS · ${_totalDurationLabel()}',
              style: textTheme.labelMedium?.copyWith(
                color: foreground.withValues(alpha: 0.6),
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        SizedBox(height: context.appSpacing.sm),
        Expanded(
          child: ListView.builder(
            controller: _controller,
            padding: EdgeInsets.zero,
            itemExtent: _rowExtent,
            itemCount: playlist.length,
            itemBuilder: (context, index) {
              final track = playlist[index];
              final isCurrent = index == widget.trackIndex;
              return Padding(
                padding: EdgeInsets.only(bottom: context.appSpacing.xs),
                child: PlaylistTrackTile(
                  trackNumber: index + 1,
                  title: track.title,
                  artist: track.artist,
                  duration: track.duration,
                  isCurrent: isCurrent,
                  isPlaying: isCurrent && widget.isPlaying,
                  // Tapping the playing track pauses it rather than
                  // restarting the song under the driver.
                  onTap: isCurrent
                      ? cubit.togglePlayPause
                      : () => cubit.playTrackAt(index),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// How long the whole playlist runs, rounded to minutes.
  String _totalDurationLabel() {
    final total = playlist.fold(
      Duration.zero,
      (sum, track) => sum + track.duration,
    );
    return '${total.inMinutes} MIN';
  }
}
