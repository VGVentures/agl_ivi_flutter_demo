import 'package:agl_ivi_vgv_demo/app/app.dart';
import 'package:agl_ivi_vgv_demo/calendar/bloc/calendar_tile_bloc.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CalendarTile extends StatelessWidget {
  const CalendarTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CalendarTileBloc()..add(const CalendarLaunched()),
      child: const CalendarTileView(),
    );
  }
}

class CalendarTileView extends StatelessWidget {
  const CalendarTileView({super.key});

  @override
  Widget build(BuildContext context) {
    // The bloc ticks in instants; the city selected in settings decides
    // which wall clock those instants are read on, and the time format
    // decides how that clock is written.
    final location = context.select<AppBloc, AppLocation>(
      (bloc) => bloc.state.location,
    );
    final timeFormat = context.select<AppBloc, AppTimeFormat>(
      (bloc) => bloc.state.timeFormat,
    );
    return BlocBuilder<CalendarTileBloc, DateTime>(
      builder: (context, currentTime) {
        return CurrentTimeCard(
          location.localTime(currentTime),
          timeFormat: timeFormat,
        );
      },
    );
  }
}
