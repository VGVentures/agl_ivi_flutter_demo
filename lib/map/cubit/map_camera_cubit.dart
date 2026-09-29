import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

/// {@template map_camera_state}
/// Where the map is looking, and where the vehicle sits in view.
/// {@endtemplate}
class MapCameraState extends Equatable {
  /// {@macro map_camera_state}
  const MapCameraState({
    required this.center,
    required this.zoom,
    required this.vehiclePosition,
  });

  /// The coordinates at the middle of the viewport.
  final LatLng center;

  /// The map's zoom level.
  final double zoom;

  /// Where the position puck is pinned.
  ///
  /// The demo parks the vehicle in whichever city is selected in settings,
  /// so this moves with that choice while the camera moves with the driver.
  final LatLng vehiclePosition;

  @override
  List<Object?> get props => [center, zoom, vehiclePosition];
}

/// {@template map_camera_cubit}
/// The camera every map in the app shares.
///
/// The home tile and the full screen overlay are two separate
/// `FlutterMap`s, each with its own internal camera. Routing both through
/// this cubit keeps them looking at the same place, so panning the overlay
/// leaves the tile framed on wherever the driver ended up rather than
/// snapping back to where it started.
/// {@endtemplate}
class MapCameraCubit extends Cubit<MapCameraState> {
  /// {@macro map_camera_cubit}
  MapCameraCubit({AppLocation location = AppLocation.berlin})
    : super(
        MapCameraState(
          center: location.coordinates,
          zoom: initialZoom,
          vehiclePosition: location.coordinates,
        ),
      );

  /// Close enough to read street names in the space the home grid gives it.
  static const initialZoom = 15.0;

  /// Records where an interactive map was moved to.
  void moved({required LatLng center, required double zoom}) => emit(
    MapCameraState(
      center: center,
      zoom: zoom,
      vehiclePosition: state.vehiclePosition,
    ),
  );

  /// Frames the vehicle again, at the zoom the map opened on.
  void recenter() => emit(
    MapCameraState(
      center: state.vehiclePosition,
      zoom: initialZoom,
      vehiclePosition: state.vehiclePosition,
    ),
  );

  /// Parks the vehicle in [location] and frames it, after the city was
  /// changed in settings.
  void locationChanged(AppLocation location) => emit(
    MapCameraState(
      center: location.coordinates,
      zoom: initialZoom,
      vehiclePosition: location.coordinates,
    ),
  );
}
