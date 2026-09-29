import 'package:agl_ivi_vgv_demo/home/home.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';

/// Opens [SettingsPage] over the home screen.
///
/// The icon is not wrapped in an [IconButton]: the tap belongs to the
/// surrounding [CardTouchTarget], and a nested button would swallow it.
class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CardTouchTarget(
      borderRadius: 30,
      // The home screen's own navigator rather than the local one, so the
      // page overlays the cards and leaves the HVAC controls this button
      // sits between visible, exactly like a card's overlay.
      onTap: () =>
          HomeNavigator.navigatorKey.currentState?.push(SettingsPage.route()),
      child: Padding(
        // Matches the touch target a default IconButton gives the icons
        // beside it.
        padding: EdgeInsets.all(context.appSpacing.xs),
        child: const RotatedBox(
          quarterTurns: -1,
          child: AppIcon(
            AppIcons.settingsSliders,
            size: AppIconSizes.control,
          ),
        ),
      ),
    );
  }
}
