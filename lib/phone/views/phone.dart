import 'package:agl_ivi_vgv_demo/phone/cubit/connected_phone_cubit.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The Phone card on the home screen.
///
/// Reads the paired handset off [ConnectedPhoneCubit] rather than holding
/// one, so the card is already badged Android Auto by the time the panel
/// that connected the Pixel closes.
class Phone extends StatelessWidget {
  const Phone({super.key});

  @override
  Widget build(BuildContext context) {
    final phone = context.watch<ConnectedPhoneCubit>().state;
    return PhoneCard(
      phoneModel: phone.name,
      projection: phone.projection,
    );
  }
}
