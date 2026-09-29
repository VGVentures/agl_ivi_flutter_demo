import 'package:agl_ivi_vgv_demo/phone/models/connected_phone.dart';
import 'package:bloc/bloc.dart';

/// {@template connected_phone_cubit}
/// Holds which handset is paired with the head unit.
///
/// Provided above `HomeNavigator` rather than inside the Phone card: the
/// card and the panel it opens are in different subtrees, and a cubit per
/// subtree would mean connecting a Pixel in the panel and closing it onto a
/// card still badged CarPlay.
/// {@endtemplate}
class ConnectedPhoneCubit extends Cubit<ConnectedPhone> {
  /// {@macro connected_phone_cubit}
  ConnectedPhoneCubit() : super(ConnectedPhone.iPhone16Pro);

  /// Pairs [phone], dropping whatever was connected before it.
  ///
  /// A head unit hosts one phone at a time, so this is a swap rather than
  /// an addition.
  void connect(ConnectedPhone phone) => emit(phone);
}
