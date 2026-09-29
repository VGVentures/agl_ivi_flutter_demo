import 'package:agl_ui/agl_ui.dart';

/// Extension on [BuildContext] for easy access to custom theme tokens.
extension AppThemeBuildContext on BuildContext {
  /// Returns the [AppSpacing] from the current theme.
  AppSpacing get appSpacing => Theme.of(this).extension<AppSpacing>()!;

  /// Returns the [AppTextStyles] from the current theme.
  AppTextStyles get appTextStyles => Theme.of(this).extension<AppTextStyles>()!;

  /// Returns the [AppCardTheme] from the current theme.
  AppCardTheme get appCardTheme => Theme.of(this).extension<AppCardTheme>()!;

  /// Returns the [AppAccentTheme] from the current theme.
  AppAccentTheme get appAccentTheme =>
      Theme.of(this).extension<AppAccentTheme>()!;

  ProfileStyleCard get profileStyleCard =>
      Theme.of(this).extension<ProfileStyleCard>()!;

  MusicPlayerStyleCard get musicPlayerStyleCard =>
      Theme.of(this).extension<MusicPlayerStyleCard>()!;

  PhoneStyleCard get phoneStyleCard =>
      Theme.of(this).extension<PhoneStyleCard>()!;

  DriveModeStyleCard get driveModeStyleCard =>
      Theme.of(this).extension<DriveModeStyleCard>()!;

  BoostCardStyle get boostCardStyle =>
      Theme.of(this).extension<BoostCardStyle>()!;

  TripEfficiencyCardStyle get tripEfficiencyCardStyle =>
      Theme.of(this).extension<TripEfficiencyCardStyle>()!;
}
