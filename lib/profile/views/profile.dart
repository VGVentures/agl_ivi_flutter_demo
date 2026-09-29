import 'package:agl_ivi_vgv_demo/profile/cubit/active_profile_cubit.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Profile card on the home screen.
///
/// Reads the driver off [ActiveProfileCubit] rather than holding one, so
/// the card is already in the new driver's name by the time the panel that
/// picked them closes.
class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ActiveProfileCubit>().state;
    return ProfileCard(
      name: profile.name,
      avatarAsset: profile.avatarAsset,
      avatarBackground: profile.avatarBackground,
    );
  }
}
