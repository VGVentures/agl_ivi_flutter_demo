import 'package:agl_ivi_vgv_demo/phone/phone.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneOverlay', () {
    late ConnectedPhoneCubit connectedPhoneCubit;

    Widget subject() {
      // Built here rather than in `setUp`: a cubit made outside the widget
      // test's zone would process its work on a queue `pump` never reaches.
      connectedPhoneCubit = ConnectedPhoneCubit();
      return BlocProvider.value(
        value: connectedPhoneCubit,
        child: MaterialApp(
          theme: AppTheme.rainbow,
          home: const Scaffold(body: PhoneOverlay()),
        ),
      );
    }

    /// Lays the panel out on a head unit sized window and settles it.
    Future<void> pumpOverlay(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();
    }

    testWidgets('lays the connected phone out beside the ones on offer', (
      tester,
    ) async {
      await pumpOverlay(tester);

      expect(find.text('CONNECTED PHONE'), findsOneWidget);
      // Once beside the connected phone's name, once in its row.
      expect(find.text(ConnectedPhone.iPhone16Pro.name), findsNWidgets(2));
      for (final phone in ConnectedPhone.values) {
        expect(find.text(phone.name), findsWidgets);
      }
    });

    testWidgets('names the projection the connected phone hands the car', (
      tester,
    ) async {
      await pumpOverlay(tester);

      expect(find.text('PROJECTING'), findsOneWidget);
      expect(find.text(PhoneProjection.carPlay.label), findsOneWidget);
    });

    testWidgets('connecting an Android moves the car onto Android Auto', (
      tester,
    ) async {
      await pumpOverlay(tester);

      await tester.tap(find.text(ConnectedPhone.pixel9Pro.name));
      await tester.pumpAndSettle();

      expect(connectedPhoneCubit.state, ConnectedPhone.pixel9Pro);
      expect(find.text(PhoneProjection.androidAuto.label), findsOneWidget);
      // The panel is now titled with the phone that was picked, so the
      // list and the column beside it cannot disagree.
      expect(find.text(ConnectedPhone.pixel9Pro.name), findsNWidgets(2));
    });

    testWidgets('marks the connected phone and only that one', (
      tester,
    ) async {
      await pumpOverlay(tester);

      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.tap(find.text(ConnectedPhone.galaxyS25Ultra.name));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });

  group('PhoneCard', () {
    Widget subject(ConnectedPhone phone) {
      return MaterialApp(
        theme: AppTheme.rainbow,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              height: 120,
              child: PhoneCard(
                phoneModel: phone.name,
                projection: phone.projection,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('badges an iPhone with CarPlay', (tester) async {
      await tester.pumpWidget(subject(ConnectedPhone.iPhone16Pro));
      await tester.pumpAndSettle();

      expect(find.text(ConnectedPhone.iPhone16Pro.name), findsOneWidget);
      expect(find.text('CARPLAY'), findsOneWidget);
    });

    testWidgets('badges an Android with Android Auto', (tester) async {
      await tester.pumpWidget(subject(ConnectedPhone.pixel9Pro));
      await tester.pumpAndSettle();

      expect(find.text(ConnectedPhone.pixel9Pro.name), findsOneWidget);
      expect(find.text('ANDROID AUTO'), findsOneWidget);
    });
  });
}
