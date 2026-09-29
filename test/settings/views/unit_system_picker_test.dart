import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UnitSystemPicker', () {
    late AppBloc appBloc;

    Widget subject() {
      appBloc = AppBloc();
      return BlocProvider.value(
        value: appBloc,
        child: MaterialApp(
          // The picker reads the app theme's spacing and accent color, so
          // it is built under one rather than Material's defaults.
          theme: AppTheme.rainbow,
          home: const Scaffold(body: UnitSystemPicker()),
        ),
      );
    }

    testWidgets('offers every unit system, previewed on a reading', (
      tester,
    ) async {
      await tester.pumpWidget(subject());

      for (final system in AppUnitSystem.values) {
        expect(find.text(system.label), findsOneWidget);
        expect(find.text(system.example), findsOneWidget);
      }
    });

    testWidgets('starts on the international system', (tester) async {
      await tester.pumpWidget(subject());

      expect(appBloc.state.unitSystem, AppUnitSystem.international);
      // Only the selected tile is checked.
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('tapping a tile selects that system', (tester) async {
      await tester.pumpWidget(subject());

      await tester.tap(find.text(AppUnitSystem.imperial.label));
      await tester.pumpAndSettle();

      expect(appBloc.state.unitSystem, AppUnitSystem.imperial);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
