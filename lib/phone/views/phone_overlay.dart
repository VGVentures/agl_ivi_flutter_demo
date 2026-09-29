import 'dart:math' as math;

import 'package:agl_ivi_vgv_demo/phone/cubit/connected_phone_cubit.dart';
import 'package:agl_ivi_vgv_demo/phone/models/connected_phone.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Phone card's overlay: the handset the head unit is paired with on
/// the leading side, and the ones it can be handed to instead beside them.
///
/// Connecting a phone is the point of the panel. The two projection
/// systems are what actually change — an iPhone hands the car CarPlay, an
/// Android hands it Android Auto — so the panel is tinted by the platform
/// in force rather than by the card's own color, and connecting across the
/// divide re-tints it.
///
/// Drives the same [ConnectedPhoneCubit] the card does — provided above
/// `HomeNavigator` — so a phone connected here is already on the card by
/// the time the panel closes.
class PhoneOverlay extends StatelessWidget {
  const PhoneOverlay({super.key});

  /// Clears the close button [CardOverlayScaffold] paints over the
  /// content's top-left corner.
  static const _closeButtonClearance = 80.0;

  /// The smallest the two columns still read at — set by the list, which
  /// needs five rows of a handset name over the platform it speaks. See
  /// [MinimumContentSize].
  ///
  /// The height has to stay under what a head unit actually leaves: the
  /// app's own padding, the permanent controls, the scaffold's inset and
  /// the close button clearance come off a 720 tall screen before this box
  /// is measured.
  static const _minimumContentSize = Size(900, 420);

  /// How long the panel takes to re-tint when the platform changes.
  static const _accentChange = Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<ConnectedPhoneCubit>().state;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.appSpacing.xlg,
        _closeButtonClearance,
        context.appSpacing.xlg,
        context.appSpacing.lg,
      ),
      child: MinimumContentSize(
        size: _minimumContentSize,
        // The panel keeps one surface whichever phone is connected, so the
        // platform comes through in the accent instead. Crossfaded rather
        // than swapped, so going from an iPhone to a Pixel re-tints the
        // panel rather than flicking it.
        child: TweenAnimationBuilder<Color?>(
          tween: ColorTween(end: phone.projection.accentColor),
          duration: _accentChange,
          curve: Curves.easeOutCubic,
          builder: (context, tinted, _) {
            final accent = tinted ?? phone.projection.accentColor;
            return Row(
              // Both columns are given the panel's full height, so each
              // lays its own content out down the side.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Proportional rather than fixed widths, so the two keep
                // their balance at every panel size.
                Flexible(
                  flex: 5,
                  child: _ConnectedPhoneDetails(phone: phone, accent: accent),
                ),
                SizedBox(width: context.appSpacing.xlg),
                Flexible(
                  flex: 4,
                  child: _PhoneList(connected: phone),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The leading column: the phone that is paired, and what the car gets out
/// of it.
class _ConnectedPhoneDetails extends StatelessWidget {
  const _ConnectedPhoneDetails({required this.phone, required this.accent});

  /// How large the washed-in platform mark is drawn before being scaled
  /// down to whatever room the column has left.
  static const _watermarkSize = 260.0;

  /// How much of the foreground the wash keeps. Matched to the drive mode
  /// panel's, so the two read as the same treatment.
  static const _watermarkOpacity = 0.07;

  final ConnectedPhone phone;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return Stack(
      children: [
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AppIcon(
              phone.projection.icon,
              size: _watermarkSize,
              color: foreground.withValues(alpha: _watermarkOpacity),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONNECTED PHONE',
                  style: textTheme.titleSmall?.copyWith(
                    color: foreground.withValues(alpha: 0.6),
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: context.appSpacing.xs),
                // The name and its mark shrink together rather than one
                // pushing the other off the column when the panel is
                // narrow.
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(phone.name, style: textTheme.displayLarge),
                      SizedBox(width: context.appSpacing.sm),
                      AppIcon(
                        phone.projection.icon,
                        size: 64,
                        color: accent,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.appSpacing.xs),
                Text(
                  '${phone.os} · ${phone.connectionLabel}',
                  style: textTheme.bodyLarge?.copyWith(
                    color: foreground.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
            _ProjectionSummary(phone: phone, accent: accent),
          ],
        ),
      ],
    );
  }
}

/// What the car actually gets from the phone that is paired.
///
/// The one block on the panel that answers why connecting one handset
/// rather than another matters, which is what makes the list worth reading.
class _ProjectionSummary extends StatelessWidget {
  const _ProjectionSummary({required this.phone, required this.accent});

  final ConnectedPhone phone;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;

    return PanelSurface(
      emphasized: true,
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'PROJECTING',
              style: textTheme.labelMedium?.copyWith(
                color: accent,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: context.appSpacing.xxs),
            Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      phone.projection.label,
                      style: textTheme.displayMedium,
                    ),
                  ),
                ),
                SizedBox(width: context.appSpacing.sm),
                Text(
                  phone.connectionLabel.toUpperCase(),
                  style: textTheme.titleSmall?.copyWith(
                    color: foreground.withValues(alpha: 0.6),
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The phones the head unit can be handed to, the paired one lifted off the
/// panel.
class _PhoneList extends StatelessWidget {
  const _PhoneList({required this.connected});

  /// How short a row is allowed to get before the list scrolls rather than
  /// squeezing further — which is what keeps the rows laid out instead of
  /// overflowing while the panel is still growing out of the card.
  ///
  /// Low enough that all five fit the shortest panel
  /// [MinimumContentSize] allows: a driver picking a phone should not have
  /// to scroll to find out which ones are paired.
  static const _minimumRowExtent = 56.0;

  final ConnectedPhone connected;

  @override
  Widget build(BuildContext context) {
    final spacing = context.appSpacing.xs;
    const phones = ConnectedPhone.values;

    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = math.max(
          constraints.maxHeight / phones.length,
          _minimumRowExtent + spacing,
        );
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemExtent: extent,
          itemCount: phones.length,
          itemBuilder: (context, index) {
            final phone = phones[index];
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: _PhoneRow(
                phone: phone,
                connected: phone == connected,
              ),
            );
          },
        );
      },
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({required this.phone, required this.connected});

  final ConnectedPhone phone;
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final foreground = textTheme.bodyMedium?.color ?? Colors.black;
    // Every row is marked in its own platform's color rather than the
    // connected one's, so the two systems can be told apart down the list
    // before a name is read.
    final accent = phone.projection.accentColor;

    return CardTouchTarget(
      borderRadius: PanelSurface.defaultBorderRadius,
      onTap: () => context.read<ConnectedPhoneCubit>().connect(phone),
      child: PanelSurface(
        emphasized: connected,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.appSpacing.md,
            vertical: context.appSpacing.xs,
          ),
          child: Row(
            children: [
              AppIcon(
                phone.projection.icon,
                size: 32,
                color: connected ? accent : foreground.withValues(alpha: 0.7),
              ),
              SizedBox(width: context.appSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      phone.name,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${phone.projection.label} · ${phone.connectionLabel}',
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
              // Only the connected row is marked: five rows each carrying
              // a status would say nothing, and the one that matters is
              // which phone the car is actually listening to.
              if (connected)
                Icon(Icons.check_circle, size: 24, color: accent)
              else
                Text(
                  phone.os,
                  style: textTheme.labelLarge?.copyWith(
                    color: foreground.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
