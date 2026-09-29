import 'package:agl_ivi_vgv_demo/map/map.dart';
import 'package:agl_ivi_vgv_demo/settings/settings.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('MapCameraCubit', () {
    const elsewhere = LatLng(52.5200, 13.4050);
    final berlin = AppLocation.berlin.coordinates;
    final tokyo = AppLocation.tokyo.coordinates;

    test('initial state frames the vehicle in Berlin', () {
      expect(
        MapCameraCubit().state,
        MapCameraState(
          center: berlin,
          zoom: MapCameraCubit.initialZoom,
          vehiclePosition: berlin,
        ),
      );
    });

    test('initial state frames the vehicle in the given location', () {
      expect(
        MapCameraCubit(location: AppLocation.tokyo).state,
        MapCameraState(
          center: tokyo,
          zoom: MapCameraCubit.initialZoom,
          vehiclePosition: tokyo,
        ),
      );
    });

    blocTest<MapCameraCubit, MapCameraState>(
      'moved records the new center and zoom',
      build: MapCameraCubit.new,
      act: (cubit) => cubit.moved(center: elsewhere, zoom: 12),
      expect: () => [
        MapCameraState(center: elsewhere, zoom: 12, vehiclePosition: berlin),
      ],
    );

    blocTest<MapCameraCubit, MapCameraState>(
      'moved leaves the vehicle where it is',
      build: MapCameraCubit.new,
      act: (cubit) => cubit.moved(center: elsewhere, zoom: 12),
      verify: (cubit) => expect(cubit.state.vehiclePosition, berlin),
    );

    blocTest<MapCameraCubit, MapCameraState>(
      'recenter returns to the vehicle after a pan',
      build: MapCameraCubit.new,
      act: (cubit) => cubit
        ..moved(center: elsewhere, zoom: 12)
        ..recenter(),
      expect: () => [
        MapCameraState(center: elsewhere, zoom: 12, vehiclePosition: berlin),
        MapCameraState(
          center: berlin,
          zoom: MapCameraCubit.initialZoom,
          vehiclePosition: berlin,
        ),
      ],
    );

    blocTest<MapCameraCubit, MapCameraState>(
      'locationChanged moves the vehicle to the new city and frames it',
      build: MapCameraCubit.new,
      act: (cubit) => cubit
        ..moved(center: elsewhere, zoom: 12)
        ..locationChanged(AppLocation.tokyo),
      expect: () => [
        MapCameraState(center: elsewhere, zoom: 12, vehiclePosition: berlin),
        MapCameraState(
          center: tokyo,
          zoom: MapCameraCubit.initialZoom,
          vehiclePosition: tokyo,
        ),
      ],
    );

    blocTest<MapCameraCubit, MapCameraState>(
      'recenter returns to the new city after a location change',
      build: MapCameraCubit.new,
      act: (cubit) => cubit
        ..locationChanged(AppLocation.tokyo)
        ..moved(center: elsewhere, zoom: 12)
        ..recenter(),
      verify: (cubit) => expect(cubit.state.center, tokyo),
    );
  });
}
