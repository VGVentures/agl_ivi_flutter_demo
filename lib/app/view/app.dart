import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/drive_mode/drive_mode.dart';
import 'package:agl_ivi_vgv_demo/home/home.dart';
import 'package:agl_ivi_vgv_demo/hvac/hvac.dart';
import 'package:agl_ivi_vgv_demo/l10n/l10n.dart';
import 'package:agl_ivi_vgv_demo/map/map.dart';
import 'package:agl_ivi_vgv_demo/music_player/music_player.dart';
import 'package:agl_ivi_vgv_demo/permanent_controls/permanent_controls.dart';
import 'package:agl_ivi_vgv_demo/phone/phone.dart';
import 'package:agl_ivi_vgv_demo/profile/profile.dart';
import 'package:agl_ivi_vgv_demo/splash/splash.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_repository/weather_repository.dart';

class App extends StatelessWidget {
  const App({required this._weatherRepository, super.key});

  final WeatherRepository _weatherRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _weatherRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AppBloc()),
          BlocProvider(create: (_) => MainStageCubit()),
          // Provided above `HomeNavigator`: the home button that flips
          // between the dashboard and the launcher sits in the permanent
          // controls strip, outside the navigator whose page it swaps.
          BlocProvider(create: (_) => HomeViewCubit()),
          BlocProvider(create: (_) => MapCameraCubit()),
          // Provided above `HomeNavigator` rather than inside the Music
          // card: the card and the overlay it opens are in different
          // subtrees, and a cubit per subtree would mean two audio players
          // playing over each other.
          BlocProvider(create: (_) => MusicPlayerCubit()),
          // Provided here for the same reason: the Drive Mode card and
          // the panel it opens sit in different subtrees, and a cubit
          // per subtree would leave the card showing the mode the
          // driver had just changed away from.
          BlocProvider(create: (_) => DriveModeCubit()),
          // And here for the same reason again: the Phone card and the
          // panel that connects a handset sit in different subtrees, and a
          // cubit per subtree would leave the card badged with whatever
          // phone the driver had just disconnected.
          BlocProvider(create: (_) => ConnectedPhoneCubit()),
          // And here again: the permanent climate controls sit below
          // `HomeNavigator` while the profile panel that presets them is
          // pushed inside it, so the cabin cannot be owned by either.
          BlocProvider(create: (_) => CabinClimateCubit()),
          // Provided above all of them: selecting a driver moves every
          // cubit listed here, so the selection has to outlive the panel
          // it is made in.
          BlocProvider(create: (_) => ActiveProfileCubit()),
        ],
        child: _AppShell(),
      ),
    );
  }
}

class _AppShell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The map owns a camera the driver can pan, so it cannot simply read
    // the city off [AppBloc] the way the weather and calendar cards do: a
    // new selection has to reset that camera.
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) => previous.location != current.location,
      listener: (context, state) =>
          context.read<MapCameraCubit>().locationChanged(state.location),
      // Above the listener, not below it: a profile sets a city through
      // [AppBloc], and the camera listener has to be in place to catch it.
      child: ActiveProfileListener(
        child: BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            return MaterialApp(
              theme: state.theme,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: AppReadyGate(child: _AppView()),
            );
          },
        ),
      ),
    );
  }
}

class _AppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(context.appSpacing.lg),
        child: const Column(
          children: [
            Expanded(child: HomeNavigator()),
            PermanentControlsPanel(),
          ],
        ),
      ),
    );
  }
}
