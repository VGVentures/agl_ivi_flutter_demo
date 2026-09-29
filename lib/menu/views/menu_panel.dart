import 'package:agl_ivi_vgv_demo/home/home.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuPanel extends StatelessWidget {
  const MenuPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: context.appSpacing.md,
      children: [
        BlocBuilder<MainStageCubit, MainStageView>(
          builder: (context, view) {
            return IconButton(
              onPressed: () => context.read<MainStageCubit>().toggle(),
              icon: AppIcon(
                // Shows where the button leads rather than where you are,
                // so it reads as "switch to this".
                switch (view) {
                  MainStageView.map => AppIcons.vehicle,
                  MainStageView.scene => AppIcons.map,
                },
                size: AppIconSizes.control,
              ),
            );
          },
        ),
        BlocBuilder<HomeViewCubit, HomeView>(
          builder: (context, view) {
            return IconButton(
              onPressed: () {
                // A card overlay is a route above whichever page is
                // showing, and swapping the page underneath would leave it
                // sitting over the one the driver asked for, so it comes
                // off first. Through the home screen's own navigator: this
                // button sits outside it, beside the HVAC controls that
                // navigator deliberately leaves uncovered.
                HomeNavigator.navigatorKey.currentState?.popUntil(
                  (route) => route.isFirst,
                );
                context.read<HomeViewCubit>().toggle();
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black,
                fixedSize: const Size(80, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: AppIcon(
                // Like the button beside it, this shows where it leads
                // rather than where you are.
                switch (view) {
                  HomeView.dashboard => AppIcons.apps,
                  HomeView.apps => AppIcons.home,
                },
                size: AppIconSizes.control,
                color: context.appAccentTheme.color,
              ),
            );
          },
        ),
        const SettingsButton(),
      ],
    );
  }
}
