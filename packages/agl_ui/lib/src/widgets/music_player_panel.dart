import 'package:agl_ui/agl_ui.dart';

/// The now-playing half of the Music card's overlay: the current track's
/// artwork filling the column, what it is underneath, a scrubbable
/// progress bar, and the transport controls.
///
/// Sized off whatever room it is given — the artwork takes the space the
/// text and controls leave — so the same widget reads at panel scale and
/// while the overlay is still growing out of the card.
class NowPlayingPanel extends StatelessWidget {
  const NowPlayingPanel({
    required this.sourceLabel,
    required this.title,
    required this.artist,
    required this.art,
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isShuffleEnabled,
    required this.isLoopEnabled,
    required this.onSeek,
    required this.onShufflePressed,
    required this.onSkipToPreviousPressed,
    required this.onPlayPausePressed,
    required this.onSkipToNextPressed,
    required this.onLoopPressed,
    super.key,
  });

  /// Where the audio is coming from, e.g. `MEDIA`.
  final String sourceLabel;

  /// The playing track's name.
  final String title;

  /// The playing track's performer.
  final String artist;

  /// The playing track's cover art.
  final ImageProvider art;

  /// How far into the track playback has reached.
  final Duration position;

  /// The track's full length.
  final Duration duration;

  /// Whether the track is playing, which the middle control reflects.
  final bool isPlaying;

  /// Whether shuffle is on, which the leading control reflects.
  final bool isShuffleEnabled;

  /// Whether repeat is on, which the trailing control reflects.
  final bool isLoopEnabled;

  /// Called with the position the driver scrubbed to.
  final ValueChanged<Duration> onSeek;

  final VoidCallback onShufflePressed;
  final VoidCallback onSkipToPreviousPressed;
  final VoidCallback onPlayPausePressed;
  final VoidCallback onSkipToNextPressed;
  final VoidCallback onLoopPressed;

  /// The radius the artwork is clipped to, a little softer than the
  /// panel's own so it reads as sitting on the surface.
  static const _artworkRadius = 24.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final accent = context.musicPlayerStyleCard.accentColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                sourceLabel,
                style: textTheme.labelMedium?.copyWith(
                  color: accent,
                  letterSpacing: 1.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppIcon(AppIcons.waveform, size: 24, color: accent),
          ],
        ),
        SizedBox(height: context.appSpacing.md),
        // Takes what the blocks around it leave rather than naming a size,
        // so the column never overflows as the panel grows into place.
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_artworkRadius),
                child: Image(image: art, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        SizedBox(height: context.appSpacing.lg),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: context.appSpacing.xxs),
        Text(
          artist,
          style: textTheme.titleMedium?.copyWith(
            color: foreground.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: context.appSpacing.md),
        MediaSeekBar(
          position: position,
          duration: duration,
          onSeek: onSeek,
        ),
        SizedBox(height: context.appSpacing.sm),
        _TransportControls(
          isPlaying: isPlaying,
          isShuffleEnabled: isShuffleEnabled,
          isLoopEnabled: isLoopEnabled,
          onShufflePressed: onShufflePressed,
          onSkipToPreviousPressed: onSkipToPreviousPressed,
          onPlayPausePressed: onPlayPausePressed,
          onSkipToNextPressed: onSkipToNextPressed,
          onLoopPressed: onLoopPressed,
        ),
      ],
    );
  }
}

/// The progress bar of a playing track, which can also be dragged to move
/// playback.
///
/// While a drag is in flight the bar follows the finger rather than the
/// stream of positions coming back from the player, so it does not snap
/// back to where playback still is between the drag and the seek landing.
class MediaSeekBar extends StatefulWidget {
  const MediaSeekBar({
    required this.position,
    required this.duration,
    required this.onSeek,
    super.key,
  });

  /// How far into the track playback has reached.
  final Duration position;

  /// The track's full length. A zero duration — nothing loaded yet — shows
  /// an empty bar that cannot be dragged.
  final Duration duration;

  /// Called once, with the position landed on, when a drag ends.
  final ValueChanged<Duration> onSeek;

  @override
  State<MediaSeekBar> createState() => _MediaSeekBarState();
}

class _MediaSeekBarState extends State<MediaSeekBar> {
  /// Where the driver has dragged to, in seconds, while a drag is running.
  double? _dragSeconds;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final accent = context.musicPlayerStyleCard.accentColor;

    final total = widget.duration.inSeconds.toDouble();
    final elapsed = _dragSeconds ?? widget.position.inSeconds.toDouble();
    // A position past the end — a stale tick from the track that just
    // finished — would be rejected by [Slider] outright.
    final value = total <= 0 ? 0.0 : elapsed.clamp(0.0, total);
    final shown = Duration(seconds: value.round());

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: accent,
            inactiveTrackColor: foreground.withValues(alpha: 0.2),
            thumbColor: accent,
            overlayColor: accent.withValues(alpha: 0.15),
            thumbShape: const RoundSliderThumbShape(),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 22),
            // The panel supplies its own padding, and the bar should line
            // up with the text above and below it.
            padding: EdgeInsets.zero,
          ),
          child: Slider(
            value: value,
            max: total <= 0 ? 1 : total,
            onChanged: total <= 0
                ? null
                : (seconds) => setState(() => _dragSeconds = seconds),
            onChangeEnd: (seconds) {
              setState(() => _dragSeconds = null);
              widget.onSeek(Duration(seconds: seconds.round()));
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.appSpacing.xxs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                shown.toMediaDuration(widget.duration),
                style: textTheme.titleSmall,
              ),
              Text(
                widget.duration.toMediaDuration(widget.duration),
                style: textTheme.titleSmall?.copyWith(
                  color: foreground.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The five transport controls, laid out the way the Music card lays them
/// out — shuffle and repeat on the ends, play in the middle — but at panel
/// size, and with shuffle and repeat showing whether they are on.
class _TransportControls extends StatelessWidget {
  const _TransportControls({
    required this.isPlaying,
    required this.isShuffleEnabled,
    required this.isLoopEnabled,
    required this.onShufflePressed,
    required this.onSkipToPreviousPressed,
    required this.onPlayPausePressed,
    required this.onSkipToNextPressed,
    required this.onLoopPressed,
  });

  final bool isPlaying;
  final bool isShuffleEnabled;
  final bool isLoopEnabled;
  final VoidCallback onShufflePressed;
  final VoidCallback onSkipToPreviousPressed;
  final VoidCallback onPlayPausePressed;
  final VoidCallback onSkipToNextPressed;
  final VoidCallback onLoopPressed;

  /// The play/pause button is drawn larger than the four around it, so the
  /// control being reached for at speed is the easiest one to hit.
  static const _primaryControlSize = 84.0;
  static const _primaryControlIconSize = 36.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MediaControlButton(
          icon: AppIcons.mediaShuffle,
          tooltip: 'Shuffle',
          isActive: isShuffleEnabled,
          onPressed: onShufflePressed,
        ),
        MediaControlButton(
          icon: AppIcons.mediaSkipPrevious,
          tooltip: 'Previous track',
          onPressed: onSkipToPreviousPressed,
        ),
        MediaControlButton(
          icon: isPlaying ? AppIcons.mediaPause : AppIcons.mediaPlay,
          tooltip: isPlaying ? 'Pause' : 'Play',
          isPrimary: true,
          size: _primaryControlSize,
          iconSize: _primaryControlIconSize,
          onPressed: onPlayPausePressed,
        ),
        MediaControlButton(
          icon: AppIcons.mediaSkipNext,
          tooltip: 'Next track',
          onPressed: onSkipToNextPressed,
        ),
        MediaControlButton(
          icon: AppIcons.mediaRepeatAlt,
          tooltip: 'Repeat',
          isActive: isLoopEnabled,
          onPressed: onLoopPressed,
        ),
      ],
    );
  }
}

/// One track in the playlist beside the player.
///
/// The playing track is lifted onto an emphasized surface and trades its
/// number for a playback indicator, so which one is on is readable at a
/// glance from the driver's seat.
class PlaylistTrackTile extends StatelessWidget {
  const PlaylistTrackTile({
    required this.trackNumber,
    required this.title,
    required this.artist,
    required this.duration,
    required this.onTap,
    this.isCurrent = false,
    this.isPlaying = false,
    super.key,
  });

  /// The track's place in the playlist, counting from one.
  final int trackNumber;

  /// The track's name.
  final String title;

  /// The track's performer.
  final String artist;

  /// The track's length.
  final Duration duration;

  /// Plays this track from the start.
  final VoidCallback onTap;

  /// Whether this is the track the player is loaded with.
  final bool isCurrent;

  /// Whether the player is playing, which only the current track shows.
  final bool isPlaying;

  /// The width the leading number and indicator share, so titles line up
  /// down the list whichever one a row is showing.
  static const _leadingWidth = 32.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    final accent = context.musicPlayerStyleCard.accentColor;
    final mutedStyle = textTheme.bodySmall?.copyWith(
      color: foreground.withValues(alpha: 0.6),
    );

    return PanelSurface(
      emphasized: isCurrent,
      child: CardTouchTarget(
        borderRadius: PanelSurface.defaultBorderRadius,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.appSpacing.md,
            vertical: context.appSpacing.sm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: _leadingWidth,
                child: isCurrent
                    ? Icon(
                        isPlaying ? Icons.graphic_eq : Icons.pause,
                        size: 20,
                        color: accent,
                      )
                    : Text(
                        '$trackNumber',
                        style: mutedStyle,
                        textAlign: TextAlign.start,
                      ),
              ),
              SizedBox(width: context.appSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.appSpacing.xxs),
                    Text(
                      artist,
                      style: mutedStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.appSpacing.sm),
              Text(duration.toMediaDuration(duration), style: mutedStyle),
            ],
          ),
        ),
      ),
    );
  }
}
