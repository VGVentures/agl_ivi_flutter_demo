import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppState(AppThemeId.values.first)) {
    on<ThemeSelected>(
      (event, emit) => emit(state.copyWith(themeId: event.themeId)),
    );
    on<LocationSelected>(
      (event, emit) => emit(state.copyWith(location: event.location)),
    );
    on<TimeFormatSelected>(
      (event, emit) => emit(state.copyWith(timeFormat: event.timeFormat)),
    );
    on<UnitSystemSelected>(
      (event, emit) => emit(state.copyWith(unitSystem: event.unitSystem)),
    );
  }
}
