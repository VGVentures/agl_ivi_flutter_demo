import 'package:agl_ivi_vgv_demo/home/home.dart';
import 'package:agl_ivi_vgv_demo/menu/menu.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MenuPanel', () {
    late HomeViewCubit homeViewCubit;

    setUp(() {
      homeViewCubit = HomeViewCubit();
    });

    tearDown(() => homeViewCubit.close());

    Widget subject() {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => MainStageCubit()),
          BlocProvider.value(value: homeViewCubit),
        ],
        child: MaterialApp(
          theme: AppTheme.rainbow,
          home: const Scaffold(body: MenuPanel()),
        ),
      );
    }

    /// The home button, found by the icon it is currently showing.
    Finder homeButton(AppIconData icon) {
      return find.ancestor(
        of: find.byWidgetPredicate(
          (widget) => widget is AppIcon && widget.data == icon,
        ),
        matching: find.byType(IconButton),
      );
    }

    testWidgets('opens the launcher from the home screen', (tester) async {
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      await tester.tap(homeButton(AppIcons.apps));
      await tester.pumpAndSettle();

      expect(homeViewCubit.state, HomeView.apps);
    });

    testWidgets('returns to the home screen from the launcher', (tester) async {
      homeViewCubit.toggle();
      await tester.pumpWidget(subject());
      await tester.pumpAndSettle();

      // The button now offers the way back rather than the way out.
      expect(homeButton(AppIcons.apps), findsNothing);

      await tester.tap(homeButton(AppIcons.home));
      await tester.pumpAndSettle();

      expect(homeViewCubit.state, HomeView.dashboard);
    });
  });
}
