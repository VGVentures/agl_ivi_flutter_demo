import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'calendar_tile_event.dart';

class CalendarTileBloc extends Bloc<CalendarLaunched, DateTime> {
  CalendarTileBloc() : super(DateTime.now()) {
    on<CalendarLaunched>(_onCalendarLaunched);
  }

  Future<void> _onCalendarLaunched(
    CalendarLaunched event,
    Emitter<DateTime> emit,
  ) async {
    await emit.onEach(
      Stream<void>.periodic(const Duration(minutes: 1)),
      onData: (_) => emit(DateTime.now()),
    );
  }
}
