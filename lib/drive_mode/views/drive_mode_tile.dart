import 'package:agl_ivi_vgv_demo/drive_mode/cubit/drive_mode_cubit.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Drive Mode card on the home screen.
///
/// Reads the mode off `DriveModeCubit` rather than holding one, so the card
/// already says Sport by the time the panel that selected it closes.
class DriveModeTile extends StatelessWidget {
  const DriveModeTile({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.select<DriveModeCubit, DriveMode>(
      (cubit) => cubit.state.mode,
    );
    return DriveModeCard(mode: mode);
  }
}
