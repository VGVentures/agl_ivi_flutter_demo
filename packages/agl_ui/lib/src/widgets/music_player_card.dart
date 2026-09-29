import 'dart:ui';

import 'package:agl_ui/agl_ui.dart';

class MusicPlayerStyleCard extends ThemeExtension<MusicPlayerStyleCard> {
  const MusicPlayerStyleCard({
    required this.backgroundColor,
    required this.accentColor,
    required this.iconColor,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final Color accentColor;

  /// The color of the shuffle/skip/repeat control icons, kept separate from
  /// [accentColor] since the play/pause button and progress bar can be a
  /// saturated accent while those icons need to stay legible against it.
  final Color iconColor;
  final double borderRadius;

  @override
  MusicPlayerStyleCard copyWith({
    Color? backgroundColor,
    Color? accentColor,
    Color? iconColor,
    double? borderRadius,
  }) {
    return MusicPlayerStyleCard(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      accentColor: accentColor ?? this.accentColor,
      iconColor: iconColor ?? this.iconColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  MusicPlayerStyleCard lerp(
    covariant ThemeExtension<MusicPlayerStyleCard>? other,
    double t,
  ) {
    if (other is! MusicPlayerStyleCard) {
      return this;
    }
    return MusicPlayerStyleCard(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      accentColor: Color.lerp(accentColor, other.accentColor, t)!,
      iconColor: Color.lerp(iconColor, other.iconColor, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}

const _artworkDimension = 100.0;
const _controlIconSize = 32.0;

class MusicPlayerCard extends StatelessWidget {
  const MusicPlayerCard({
    required this.mediaType,
    required this.mediaName,
    required this.mediaAuthor,
    required this.mediaArt,
    required this.mediaPlayedProgress,
    required this.mediaDuration,
    required this.isPlaying,
    required this.isShuffleEnabled,
    required this.isLoopEnabled,
    required this.onShufflePressed,
    required this.onSkipToPreviousPressed,
    required this.onPlayPausePressed,
    required this.onSkipToNextPressed,
    required this.onLoopPressed,
    super.key,
  });

  final String mediaType;
  final String mediaName;
  final String mediaAuthor;
  final AssetImage mediaArt;
  final Duration mediaPlayedProgress;
  final Duration mediaDuration;
  final bool isPlaying;

  /// Whether [onShufflePressed] has shuffle turned on, which the control
  /// shows.
  final bool isShuffleEnabled;

  /// Whether [onLoopPressed] has repeat turned on, which the control shows.
  final bool isLoopEnabled;

  final VoidCallback onShufflePressed;
  final VoidCallback onSkipToPreviousPressed;
  final VoidCallback onPlayPausePressed;
  final VoidCallback onSkipToNextPressed;
  final VoidCallback onLoopPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = context.musicPlayerStyleCard;
    final foregroundColor = style.backgroundColor
        .blackOrWhiteAccessibleContrastColor();
    return Card(
      color: style.backgroundColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.lg),
        child: Theme(
          data: theme.copyWith(
            textTheme: theme.textTheme.apply(
              bodyColor: foregroundColor,
              displayColor: foregroundColor,
            ),
            iconTheme: theme.iconTheme.copyWith(color: foregroundColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MediaInformation(
                mediaType: mediaType,
                mediaName: mediaName,
                mediaAuthor: mediaAuthor,
                mediaArt: mediaArt,
              ),
              _MediaProgress(
                mediaPlayedProgress: mediaPlayedProgress,
                mediaDuration: mediaDuration,
              ),
              _MediaControls(
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
          ),
        ),
      ),
    );
  }
}

class _MediaInformation extends StatelessWidget {
  const _MediaInformation({
    required this.mediaType,
    required this.mediaName,
    required this.mediaAuthor,
    required this.mediaArt,
  });

  final String mediaType;
  final String mediaName;
  final String mediaAuthor;
  final AssetImage mediaArt;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox.square(
          dimension: _artworkDimension,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(image: mediaArt),
          ),
        ),
        SizedBox(width: context.appSpacing.md),
        Expanded(
          // Matching the artwork height lets the source label sit against the
          // artwork's top edge and the track details against its bottom edge.
          child: SizedBox(
            height: _artworkDimension,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        mediaType,
                        style: ts.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.graphic_eq),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mediaName,
                      style: ts.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      mediaAuthor,
                      style: ts.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MediaProgress extends StatelessWidget {
  const _MediaProgress({
    required this.mediaPlayedProgress,
    required this.mediaDuration,
  });

  final Duration mediaPlayedProgress;
  final Duration mediaDuration;

  @override
  Widget build(BuildContext context) {
    final style = context.musicPlayerStyleCard;
    final ts = Theme.of(context).textTheme;
    return Row(
      children: [
        Text(
          mediaPlayedProgress.toMediaDuration(mediaDuration),
          style: ts.titleMedium,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.appSpacing.md),
            child: LinearProgressIndicator(
              value: mediaPlayedProgress.percentageOfProgress(mediaDuration),
              color: style.accentColor,
              backgroundColor: style.accentColor
                  .blackOrWhiteAccessibleContrastColor(),
            ),
          ),
        ),
        Text(
          mediaDuration.toMediaDuration(mediaDuration),
          style: ts.titleMedium,
        ),
      ],
    );
  }
}

class _MediaControls extends StatelessWidget {
  const _MediaControls({
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

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MediaControlButton(
          icon: AppIcons.mediaShuffle,
          tooltip: 'Shuffle',
          isActive: isShuffleEnabled,
          iconSize: _controlIconSize,
          onPressed: onShufflePressed,
        ),
        MediaControlButton(
          icon: AppIcons.mediaSkipPrevious,
          tooltip: 'Previous track',
          iconSize: _controlIconSize,
          onPressed: onSkipToPreviousPressed,
        ),
        MediaControlButton(
          icon: isPlaying ? AppIcons.mediaPause : AppIcons.mediaPlay,
          tooltip: isPlaying ? 'Pause' : 'Play',
          isPrimary: true,
          iconSize: _controlIconSize,
          onPressed: onPlayPausePressed,
        ),
        MediaControlButton(
          icon: AppIcons.mediaSkipNext,
          tooltip: 'Next track',
          iconSize: _controlIconSize,
          onPressed: onSkipToNextPressed,
        ),
        MediaControlButton(
          icon: AppIcons.mediaRepeatAlt,
          tooltip: 'Repeat',
          isActive: isLoopEnabled,
          iconSize: _controlIconSize,
          onPressed: onLoopPressed,
        ),
      ],
    );
  }
}
