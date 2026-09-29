import 'package:agl_ui/agl_ui.dart';

/// Splash logos, decoded at roughly the size they render at rather than
/// their full source resolution, which keeps the decode and the texture
/// upload cheap on low-powered hardware.
const aglLogoImage = ResizeImage(
  AssetImage('assets/branding/agl_logo.png'),
  width: 840,
);
const vgvLogoImage = ResizeImage(
  AssetImage('assets/branding/vgv_logo.png'),
  width: 480,
);

/// Branded splash shown while the app warms up, until `AppReadyGate`
/// reveals the real UI.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  // The logos have very different aspect ratios, so they are sized by height
  // to sit evenly next to each other.
  static const _logoHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.appSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'IVI Flutter Demo\nBuilt By',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: context.appSpacing.xxlg),
              FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Image(image: aglLogoImage, height: _logoHeight),
                    SizedBox(width: context.appSpacing.xxlg),
                    const Image(image: vgvLogoImage, height: _logoHeight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
