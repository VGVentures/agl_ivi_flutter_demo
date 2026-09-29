part of 'cabin_climate_cubit.dart';

/// {@template cabin_climate_state}
/// What each side of the cabin is set to.
///
/// The two are held together rather than apart so one cubit can serve both
/// panels: see [CabinClimateCubit].
/// {@endtemplate}
final class CabinClimateState extends Equatable {
  /// {@macro cabin_climate_state}
  const CabinClimateState({
    this.driver = const CabinClimate(),
    this.passenger = const CabinClimate(),
  });

  /// The driver's side.
  final CabinClimate driver;

  /// The passenger's side.
  final CabinClimate passenger;

  /// What [side] is set to.
  CabinClimate of(CabinSide side) => switch (side) {
    CabinSide.driver => driver,
    CabinSide.passenger => passenger,
  };

  /// A copy with [side] set to [climate], the other side left alone.
  CabinClimateState withSide(CabinSide side, CabinClimate climate) =>
      switch (side) {
        CabinSide.driver => CabinClimateState(
          driver: climate,
          passenger: passenger,
        ),
        CabinSide.passenger => CabinClimateState(
          driver: driver,
          passenger: climate,
        ),
      };

  @override
  List<Object?> get props => [driver, passenger];
}
