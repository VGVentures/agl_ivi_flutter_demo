import 'package:agl_ivi_vgv_demo/phone/phone.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectedPhoneCubit', () {
    test('starts on the phone the home screen was designed with', () {
      expect(ConnectedPhoneCubit().state, ConnectedPhone.iPhone16Pro);
    });

    blocTest<ConnectedPhoneCubit, ConnectedPhone>(
      'connect pairs the phone',
      build: ConnectedPhoneCubit.new,
      act: (cubit) => cubit.connect(ConnectedPhone.pixel9Pro),
      expect: () => [ConnectedPhone.pixel9Pro],
    );

    blocTest<ConnectedPhoneCubit, ConnectedPhone>(
      'connecting drops whatever was paired before it',
      build: ConnectedPhoneCubit.new,
      act: (cubit) => cubit
        ..connect(ConnectedPhone.pixel9Pro)
        ..connect(ConnectedPhone.iPhoneSe),
      expect: () => [ConnectedPhone.pixel9Pro, ConnectedPhone.iPhoneSe],
    );
  });

  group('ConnectedPhone', () {
    test('an iPhone hands the car CarPlay and an Android, Android Auto', () {
      expect(
        ConnectedPhone.iPhone16Pro.projection,
        PhoneProjection.carPlay,
      );
      expect(
        ConnectedPhone.pixel9Pro.projection,
        PhoneProjection.androidAuto,
      );
    });

    test('the list covers both platforms and both ways of connecting', () {
      // The panel exists to show what swapping platforms does to the car,
      // which it cannot do off a list that only holds iPhones.
      expect(
        ConnectedPhone.values.map((phone) => phone.projection).toSet(),
        PhoneProjection.values.toSet(),
      );
      expect(
        ConnectedPhone.values.map((phone) => phone.isWireless).toSet(),
        {true, false},
      );
    });

    test('says how it is connected', () {
      expect(ConnectedPhone.iPhone16Pro.connectionLabel, 'Wireless');
      expect(ConnectedPhone.iPhoneSe.connectionLabel, 'USB');
    });
  });
}
