import 'package:agl_ui/agl_ui.dart';

/// The modes the car can be driven in.
///
/// The design system's own vocabulary: one glyph, one name and one washed-in
/// outline each, so a mode is drawn the same way on the card, in the panel's
/// list and beside the active mode's name. What a mode actually *does* to the
/// car — throttle map, regen, how much range it costs — is the app's
/// business, not the design system's, and is attached there.
///
/// [DriveModeStyleCard] pairs each value with the colors it is painted in.
enum DriveMode {
  comfort(
    label: 'Comfort',
    icon: AppIcons.driveComfort,
    watermark: 'drive_comfort',
  ),
  eco(
    label: 'Eco',
    icon: AppIcons.driveEco,
    watermark: 'eco_plant',
  ),
  sport(
    label: 'Sport',
    icon: AppIcons.driveSport,
    watermark: 'drive_sport',
  ),
  snow(
    label: 'Snow',
    icon: AppIcons.driveSnow,
    watermark: 'drive_snow',
  ),
  custom(
    label: 'Custom',
    icon: AppIcons.driveCustom,
    watermark: 'drive_custom',
  );

  const DriveMode({
    required this.label,
    required this.icon,
    required String watermark,
  }) : watermarkAsset = 'packages/agl_ui/assets/$watermark.svg';

  /// The mode written out, for the card and the one line that names it.
  final String label;

  /// The glyph that stands for it in a list, or beside its own name.
  final AppIconData icon;

  /// The outline of this mode, which [DriveModeCard] washes behind itself.
  ///
  /// Kept apart from [icon] for the reason [WeatherTreatment] keeps the two
  /// apart: the icon is a solid glyph sized for a list, the watermark a
  /// large faint silhouette that only reads at card scale.
  final String watermarkAsset;
}

/// {@template drive_mode_style_card}
/// The colors each [DriveMode] is painted in.
///
/// One [AppCardStyle] per mode rather than one for the card, because picking
/// a mode repaints the card: the point of the Drive Mode tile is that the
/// mode reads from across the cabin, before the name does. Resolve a mode's
/// style with [styleFor] rather than reaching for the fields, so no caller
/// has to switch over the enum itself.
///
/// Every mode names the same [AppCardStyle.overlayBackground]. The panel a
/// mode opens onto is one surface whatever is selected on it — five modes
/// each repainting the whole panel would be exhausting to flick through —
/// and the mode comes through in [AppCardStyle.accentColor] instead.
/// {@endtemplate}
@immutable
class DriveModeStyleCard extends ThemeExtension<DriveModeStyleCard> {
  /// {@macro drive_mode_style_card}
  const DriveModeStyleCard({
    required this.comfort,
    required this.eco,
    required this.sport,
    required this.snow,
    required this.custom,
  });

  final AppCardStyle comfort;
  final AppCardStyle eco;
  final AppCardStyle sport;
  final AppCardStyle snow;
  final AppCardStyle custom;

  /// The style [mode] is painted in.
  AppCardStyle styleFor(DriveMode mode) => switch (mode) {
    DriveMode.comfort => comfort,
    DriveMode.eco => eco,
    DriveMode.sport => sport,
    DriveMode.snow => snow,
    DriveMode.custom => custom,
  };

  @override
  DriveModeStyleCard copyWith({
    AppCardStyle? comfort,
    AppCardStyle? eco,
    AppCardStyle? sport,
    AppCardStyle? snow,
    AppCardStyle? custom,
  }) {
    return DriveModeStyleCard(
      comfort: comfort ?? this.comfort,
      eco: eco ?? this.eco,
      sport: sport ?? this.sport,
      snow: snow ?? this.snow,
      custom: custom ?? this.custom,
    );
  }

  @override
  DriveModeStyleCard lerp(
    covariant ThemeExtension<DriveModeStyleCard>? other,
    double t,
  ) {
    if (other is! DriveModeStyleCard) return this;
    return DriveModeStyleCard(
      comfort: comfort.lerp(other.comfort, t),
      eco: eco.lerp(other.eco, t),
      sport: sport.lerp(other.sport, t),
      snow: snow.lerp(other.snow, t),
      custom: custom.lerp(other.custom, t),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DriveModeStyleCard &&
        other.comfort == comfort &&
        other.eco == eco &&
        other.sport == sport &&
        other.snow == snow &&
        other.custom == custom;
  }

  @override
  int get hashCode => Object.hash(comfort, eco, sport, snow, custom);
}

/// The Drive Mode tile: which mode the car is in, over that mode's own color
/// and silhouette.
///
/// Changing mode crossfades the card rather than swapping it, so a mode
/// picked in the panel — or suggested by the weather and accepted — arrives
/// as the card turning into the new one.
class DriveModeCard extends StatelessWidget {
  const DriveModeCard({required this.mode, super.key});

  /// How long the card takes to change mode.
  static const _modeChange = Duration(milliseconds: 400);

  /// Clears the card's rounded bottom-right corner, so the silhouette sits
  /// inside the shape rather than being cut by it.
  static const _watermarkInset = 12.0;

  /// The mode the car is currently in.
  final DriveMode mode;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<AppCardStyle>(
      tween: _AppCardStyleTween(end: context.driveModeStyleCard.styleFor(mode)),
      duration: _modeChange,
      curve: Curves.easeOutCubic,
      builder: (context, style, _) => AppCard(
        style: style,
        title: 'DRIVE MODE',
        background: Align(
          alignment: AlignmentDirectional.bottomEnd,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: _watermarkInset),
            child: AnimatedSwitcher(
              duration: _modeChange,
              child: SvgPicture.asset(
                mode.watermarkAsset,
                key: ValueKey(mode),
                semanticsLabel: '${mode.label} drive mode',
              ),
            ),
          ),
        ),
        // The longest name is nearly twice the shortest, so the mode is
        // scaled down to the card rather than left to wrap or clip.
        content: Builder(
          builder: (context) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              mode.label,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
        ),
      ),
    );
  }
}

/// Interpolates between two [AppCardStyle]s, which [Tween] cannot do on its
/// own: the default `lerp` needs a type that supports `+` and `*`, and a
/// style carries decorations rather than numbers.
class _AppCardStyleTween extends Tween<AppCardStyle> {
  _AppCardStyleTween({super.end});

  @override
  AppCardStyle lerp(double t) => begin!.lerp(end!, t);
}
