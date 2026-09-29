import 'package:agl_ivi_vgv_demo/hvac/models/cabin_climate.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'cabin_climate_state.dart';

/// {@template cabin_climate_cubit}
/// Holds what both sides of the cabin are set to.
///
/// Provided above the app shell rather than inside `HvacPanel`: the panel
/// draws one side, but a driver profile hands the cabin a whole preset from
/// an overlay in a different subtree, and state owned by the panel would be
/// out of that overlay's reach.
///
/// One cubit for both sides rather than one per panel, because the two
/// panels sit side by side in the same tree and a lookup by type could not
/// tell them apart. Every mutator therefore names the side it moves.
/// {@endtemplate}
class CabinClimateCubit extends Cubit<CabinClimateState> {
  /// {@macro cabin_climate_cubit}
  CabinClimateCubit() : super(const CabinClimateState());

  /// Sets [side]'s target temperature to [temperature].
  void setTemperature(CabinSide side, double temperature) =>
      _update(side, (climate) => climate.withTemperature(temperature));

  /// Advances [side]'s fan to the next speed.
  void cycleFanSpeed(CabinSide side) =>
      _update(side, (climate) => climate.withNextFanSpeed());

  /// Advances [side]'s seat to the next recline position.
  void cycleSeatRecline(CabinSide side) =>
      _update(side, (climate) => climate.withNextSeatRecline());

  /// Advances [side]'s seat heater to the next level.
  void cycleSeatHeat(CabinSide side) =>
      _update(side, (climate) => climate.withNextSeatHeat());

  /// Switches [side]'s air conditioning the other way.
  void toggleAc(CabinSide side) =>
      _update(side, (climate) => climate.withAcToggled());

  /// Sets [side] to [climate] in one move.
  ///
  /// How a driver profile lands: the whole side at once, so the controls
  /// never sit half in the old driver's settings and half in the new one's.
  /// Defaults to the driver's side — a driver profile says nothing about
  /// how the passenger likes to sit.
  void apply(CabinClimate climate, {CabinSide side = CabinSide.driver}) =>
      emit(state.withSide(side, climate));

  void _update(CabinSide side, CabinClimate Function(CabinClimate) change) =>
      emit(state.withSide(side, change(state.of(side))));
}
