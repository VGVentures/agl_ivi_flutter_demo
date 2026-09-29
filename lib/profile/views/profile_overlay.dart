import 'dart:math' as math;

import 'package:agl_ivi_vgv_demo/hvac/hvac.dart';
import 'package:agl_ivi_vgv_demo/profile/cubit/active_profile_cubit.dart';
import 'package:agl_ivi_vgv_demo/profile/models/driver_profile.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Profile card's overlay: the driver the car is set up for on the
/// leading side, the ones it can be handed to beside them, and everything
/// the selection sets along the foot.
///
/// The strip along the bottom is the point of the panel. A profile is not a
/// name badge — it is a theme, a city, a clock, a set of units, a drive
/// mode, a paired handset and a cabin, all moved at once — and the strip is
/// where that is visible before the panel is even closed.
///
/// Drives the same [ActiveProfileCubit] the card does, provided above
/// `HomeNavigator`, with `ActiveProfileListener` above that pushing the
/// selection into the blocs that own each of those settings.
class ProfileOverlay extends StatelessWidget {
  const ProfileOverlay({super.key});

  /// Clears the close button [CardOverlayScaffold] paints over the
  /// content's top-left corner.
  static const _closeButtonClearance = 80.0;

  /// The smallest the panel still reads at — set by the strip, which needs
  /// seven settings side by side with a word on each. See
  /// [MinimumContentSize].
  ///
  /// The height has to stay under what a head unit actually leaves: the
  /// app's own padding, the permanent controls, the scaffold's inset and
  /// the close button clearance come off a 720 tall screen before this box
  /// is measured.
  static const _minimumContentSize = Size(900, 440);

  /// How long the panel takes to re-tint when the driver changes.
  static const _accentChange = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileCubit>().state;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.appSpacing.xlg,
        _closeButtonClearance,
        context.appSpacing.xlg,
        context.appSpacing.lg,
      ),
      child: MinimumContentSize(
        size: _minimumContentSize,
        // The panel keeps one surface whichever driver is selected, so the
        // driver comes through in the accent instead. Crossfaded rather
        // than swapped, so picking one re-tints the panel rather than
        // flicking it — and the theme underneath is changing at the same
        // time.
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: profile.avatarBackground),
          duration: _accentChange,
          curve: Curves.easeOutCubic,
          builder: (context, tinted, _) {
            final accent = tinted ?? profile.avatarBackground;
            return Column(
              children: [
                Expanded(
                  // Both columns are given the panel's height above the
                  // strip, so each lays its own content out down the side.
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Proportional rather than fixed widths, so the two
                      // keep their balance at every panel size. Expanded
                      // rather than Flexible: a loose column would take
                      // only the width its own content needs and leave the
                      // slack at the end of the row, which would float the
                      // list off the panel's right edge and out of line
                      // with the strip below it.
                      Expanded(
                        flex: 5,
                        child: _ActiveDriver(profile: profile, accent: accent),
                      ),
                      SizedBox(width: context.appSpacing.xlg),
                      Expanded(
                        flex: 4,
                        child: _ProfileList(selected: profile),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.appSpacing.lg),
                _SettingsStrip(profile: profile, accent: accent),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The leading column: who the car is set up for.
class _ActiveDriver extends StatelessWidget {
  const _ActiveDriver({required this.profile, required this.accent});

  /// The circle the portrait is drawn on at the head of the panel.
  ///
  /// Large enough to be looked at rather than identified from: this is the
  /// one place a driver's face is the subject rather than a label beside
  /// their name.
  static const _portraitSize = 132.0;

  final DriverProfile profile;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    // Stacked rather than set side by side: a portrait beside the name
    // leaves the column's whole lower half empty, and one above it fills
    // the height the list beside it already uses.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // Laid out from the top of the column, level with the first row of
      // the list beside it, rather than centered against the whole of it.
      children: [
        Text(
          'ACTIVE DRIVER',
          style: textTheme.titleSmall?.copyWith(
            color: foreground.withValues(alpha: 0.6),
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: context.appSpacing.md),
        // The portrait gives up its size first when the panel is short,
        // so the name it belongs to is never the thing that is cropped.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.topStart,
            child: ProfileAvatar(
              assetName: profile.avatarAsset,
              background: profile.avatarBackground,
              size: _portraitSize,
            ),
          ),
        ),
        SizedBox(height: context.appSpacing.md),
        // The name shrinks rather than wrapping or clipping, so a long one
        // still reads as the panel's title.
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: Text(profile.name, style: textTheme.displayLarge),
        ),
        SizedBox(height: context.appSpacing.xs),
        Text(
          profile.tagline.toUpperCase(),
          style: textTheme.titleSmall?.copyWith(
            color: accent,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

/// The drivers the car can be handed to, the selected one lifted off the
/// panel.
class _ProfileList extends StatelessWidget {
  const _ProfileList({required this.selected});

  /// How short a row is allowed to get before the list scrolls rather than
  /// squeezing further — which is what keeps the rows laid out instead of
  /// overflowing while the panel is still growing out of the card.
  ///
  /// Low enough that all five fit the shortest panel
  /// [MinimumContentSize] allows: a driver picking their own profile should
  /// not have to scroll to find it.
  static const _minimumRowExtent = 56.0;

  final DriverProfile selected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing.xs;
    const profiles = DriverProfile.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = math.max(
          constraints.maxHeight / profiles.length,
          _minimumRowExtent + spacing,
        );
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemExtent: extent,
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: _ProfileRow(
                profile: profile,
                selected: profile == selected,
              ),
            );
          },
        );
      },
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.profile, required this.selected});

  /// The avatar as it is drawn down the list.
  static const _avatarSize = 40.0;

  final DriverProfile profile;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return CardTouchTarget(
      borderRadius: PanelSurface.defaultBorderRadius,
      onTap: () => context.read<ActiveProfileCubit>().select(profile),
      child: PanelSurface(
        emphasized: selected,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.appSpacing.md,
            vertical: context.appSpacing.xs,
          ),
          child: Row(
            children: [
              ProfileAvatar(
                assetName: profile.avatarAsset,
                background: profile.avatarBackground,
                size: _avatarSize,
              ),
              SizedBox(width: context.appSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      profile.tagline.toUpperCase(),
                      style: textTheme.labelSmall?.copyWith(
                        color: foreground.withValues(alpha: 0.6),
                        letterSpacing: 1.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: context.appSpacing.xs),
              // Only the selected row is marked: five rows each carrying a
              // status would say nothing, and the one that matters is which
              // driver the car is actually set up for.
              if (selected)
                Icon(
                  Icons.check_circle,
                  size: 24,
                  color: profile.avatarBackground,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Everything the selected profile sets, laid out across the foot of the
/// panel.
///
/// One block per setting rather than a paragraph naming them: the blocks
/// stay in place as the driver changes, so switching profiles reads as
/// seven values being rewritten rather than a new sentence appearing.
class _SettingsStrip extends StatelessWidget {
  const _SettingsStrip({required this.profile, required this.accent});

  final DriverProfile profile;
  final Color accent;

  /// How the cabin preset is written out: the temperature always, and the
  /// controls that are actually doing something after it.
  ///
  /// Built from the same [CabinClimate] the controls are handed, so the
  /// strip cannot promise a setting the cabin does not land on.
  static String _cabinSummary(CabinClimate climate) {
    return [
      '${climate.temperature.round()}°',
      if (climate.fanSpeed > 0) 'FAN ${climate.fanSpeed}',
      if (climate.isAcOn) 'A/C',
      if (climate.seatHeat > 0) 'HEAT ${climate.seatHeat}',
      if (climate.seatRecline > 0) 'RECLINE ${climate.seatRecline}',
    ].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return PanelSurface(
      emphasized: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.appSpacing.md,
          vertical: context.appSpacing.sm,
        ),
        child: Row(
          spacing: context.appSpacing.sm,
          children: [
            _Setting(
              icon: AppIcons.palette,
              label: 'THEME',
              value: profile.themeId.label,
              accent: accent,
            ),
            _Setting(
              icon: AppIcons.map,
              label: 'LOCATION',
              value: profile.location.label,
              accent: accent,
            ),
            _Setting(
              icon: AppIcons.ruler,
              label: 'UNITS',
              value: profile.unitSystem.label,
              accent: accent,
            ),
            _Setting(
              icon: AppIcons.clock,
              label: 'CLOCK',
              value: profile.timeFormat.label,
              accent: accent,
            ),
            _Setting(
              icon: profile.driveMode.icon,
              label: 'DRIVE MODE',
              value: profile.driveMode.label,
              accent: accent,
            ),
            _Setting(
              icon: profile.phone.projection.icon,
              label: 'PHONE',
              value: profile.phone.name,
              accent: accent,
            ),
            _Setting(
              icon: AppIcons.iconFan,
              label: 'CABIN',
              value: _cabinSummary(profile.climate),
              accent: accent,
            ),
          ],
        ),
      ),
    );
  }
}

/// One setting on the strip: what it is, and where this profile leaves it.
class _Setting extends StatelessWidget {
  const _Setting({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final AppIconData icon;
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(icon, size: 16, color: accent),
              SizedBox(width: context.appSpacing.xxs),
              Expanded(
                child: Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: foreground.withValues(alpha: 0.6),
                    letterSpacing: 1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: context.appSpacing.xxs),
          // The values are what change when a driver is picked, so they are
          // scaled to fit rather than clipped: a profile whose phone has a
          // long name still shows the whole of it.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}
