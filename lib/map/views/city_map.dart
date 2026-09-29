import 'package:agl_ivi_vgv_demo/map/cubit/map_camera_cubit.dart';
import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// A map of the selected city, framed by the shared [MapCameraCubit].
///
/// Tiles are raster PNGs fetched over HTTP and painted by Flutter itself, so
/// this needs no platform view and runs unchanged on the Raspberry Pi's
/// `drm-kms-egl` embedder.
class CityMap extends StatefulWidget {
  /// The map as it sits in the home grid: clipped to the home screen's card
  /// radius and inert, so a passenger cannot knock the demo off center by
  /// brushing the screen. It follows the shared camera rather than driving
  /// it, which is how a pan in the overlay shows up here.
  const CityMap({super.key})
    : _interactiveFlags = InteractiveFlag.none,
      _borderRadius = _tileBorderRadius,
      _isExpanded = false;

  /// The map as it fills the card overlay: pannable and zoomable, driving
  /// the shared camera as it moves, and carrying the credit
  /// OpenStreetMap's tile usage policy asks for.
  ///
  /// Corners are left square because `CardOverlayScaffold` already clips the
  /// overlay to its own radius.
  const CityMap.expanded({super.key})
    : // Rotation is left out: a map that can end up pointing anywhere but
      // north is disorienting on a dashboard.
      _interactiveFlags = InteractiveFlag.all & ~InteractiveFlag.rotate,
      _borderRadius = null,
      _isExpanded = true;

  /// Shows through until the first tiles arrive, so a slow or missing
  /// network leaves a flat panel rather than a checkerboard of holes.
  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  static const _tileBorderRadius = 30.0;

  final int _interactiveFlags;
  final double? _borderRadius;
  final bool _isExpanded;

  @override
  State<CityMap> createState() => _CityMapState();
}

class _CityMapState extends State<CityMap> {
  final _controller = MapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Reports a driver-initiated move so the other map can follow it.
  ///
  /// Only the expanded map is interactive, so only it ever reports. Both
  /// maps listen, but an echo cannot loop: the state emitted here already
  /// matches this map's own camera, and [MapController.move] does nothing
  /// when asked for the position it is already at.
  void _report(MapCamera camera, {required bool hasGesture}) {
    if (!hasGesture) return;
    context.read<MapCameraCubit>().moved(
      center: camera.center,
      zoom: camera.zoom,
    );
  }

  /// Catches this map up to the shared camera: the tile after the overlay
  /// was panned, or the expanded map after a recenter.
  void _follow(BuildContext context, MapCameraState state) {
    _controller.move(state.center, state.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final camera = context.read<MapCameraCubit>().state;
    // Unlike the camera, which the [BlocListener] below hands straight to
    // the controller, the puck is painted by this build — so it has to
    // watch for the city changing under it.
    final vehiclePosition = context.select<MapCameraCubit, LatLng>(
      (cubit) => cubit.state.vehiclePosition,
    );
    final map = ColoredBox(
      color: CityMap.backgroundColor(context),
      child: FlutterMap(
        mapController: _controller,
        options: MapOptions(
          // Only seeds the first frame. Everything after it arrives through
          // the BlocListener below.
          initialCenter: camera.center,
          initialZoom: camera.zoom,
          interactionOptions: InteractionOptions(
            flags: widget._interactiveFlags,
          ),
          onPositionChanged: widget._isExpanded
              ? (camera, hasGesture) => _report(camera, hasGesture: hasGesture)
              : null,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'ventures.verygood.agl_ivi_vgv_demo',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: vehiclePosition,
                width: 28,
                height: 28,
                child: _PositionPuck(color: context.appAccentTheme.color),
              ),
            ],
          ),
          if (widget._isExpanded) ...[
            const _RecenterButton(),
            const _Attribution(),
          ],
        ],
      ),
    );

    final borderRadius = widget._borderRadius;
    return BlocListener<MapCameraCubit, MapCameraState>(
      listener: _follow,
      child: borderRadius == null
          ? map
          : ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              // FlutterMap's gesture detector claims taps even with every
              // interaction flag off, which would swallow the ones meant
              // for the CardOverlayTarget wrapping the tile. Nothing here
              // is interactive, so let pointers straight through to it.
              child: IgnorePointer(child: map),
            ),
    );
  }
}

/// The "you are here" dot, pinned to the vehicle as the camera moves.
class _PositionPuck extends StatelessWidget {
  const _PositionPuck({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

/// Frames the vehicle again after the driver has panned away.
///
/// Without it, panning the overlay and closing it would strand the home
/// tile wherever the driver left off, with no way back short of a restart.
class _RecenterButton extends StatelessWidget {
  const _RecenterButton();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.md),
        child: IconButton.filledTonal(
          onPressed: () => context.read<MapCameraCubit>().recenter(),
          icon: const Icon(Icons.my_location),
        ),
      ),
    );
  }
}

/// The tile credit OpenStreetMap's usage policy requires.
///
/// Hand rolled rather than [SimpleAttributionWidget], which prefixes the
/// credit with flutter_map's own name.
class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.sm),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.appSpacing.xs,
              vertical: context.appSpacing.xxs,
            ),
            child: Text(
              '© OpenStreetMap contributors',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
