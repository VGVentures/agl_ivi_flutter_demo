import 'dart:async';

import 'package:agl_ui/agl_ui.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart' as vm;

/// How long to keep rendering after the last input event, so the camera's
/// eased motion (default `smoothing: 0.12`s, ~99% settled by 5x that) has
/// time to finish before rendering stops.
const _settleDelay = Duration(milliseconds: 700);

/// Fraction of the device pixel ratio the scene renders at before Flutter
/// scales it back up to the widget's size.
///
/// The car is a glossy, curved, low-contrast subject, so the softening this
/// introduces is close to invisible, while fragment work (the shading pass,
/// and every screen-space pass that runs at render-target resolution) scales
/// with the square of this: 0.6 costs about 36% of the pixels. This is the
/// cheapest quality/throughput dial in the scene and the first one to reach
/// for on a low-power GPU such as the Raspberry Pi's VideoCore.
const _renderScale = 0.6;

/// The imported car model's local bounding box, read from its glTF source.
/// Used to frame the camera and size the ground shadow catcher without
/// waiting on an async load.
final _carBounds = vm.Aabb3.minMax(
  vm.Vector3(-0.9, 0.01, -2.11),
  vm.Vector3(0.9, 1.19, 2.11),
);

/// Local extent of the shadow catcher plane.
///
/// Sized to the car's footprint plus room for the shadow to stretch, rather
/// than an arbitrarily large ground plane: the catcher is translucent
/// geometry that also joins the depth prepass, so every pixel it covers is
/// paid for whether or not a shadow lands there. [_catcherFadeStart] and
/// [_catcherFadeEnd] fade the overlay out radially so the smaller plane has
/// no visible edge.
const _catcherExtent = 5.0;
const _catcherFadeStart = 1.9;
const _catcherFadeEnd = 2.5;

/// Shows the car model in a photo-studio backdrop, with a shadow-catcher
/// plane grounding it and an orbit camera the user can drag to look around
/// it (pinch or scroll to zoom).
class ParkedCarScene extends StatefulWidget {
  const ParkedCarScene({super.key});

  @override
  State<ParkedCarScene> createState() => _ParkedCarSceneState();
}

class _ParkedCarSceneState extends State<ParkedCarScene> {
  late final OrbitCameraController _orbit;

  // Nothing in this scene moves, so the shadow the car drops on the ground is
  // the same every frame. Baked mode renders it once into a small blurred
  // footprint cache and samples that, instead of filtering the shadow atlas
  // per fragment on every frame. Softness maps to the cache's blur radius and
  // resolution here, so a softer shadow is cheaper rather than more
  // expensive, unlike the live path where it widens a per-fragment kernel.
  //
  // The cache is not invalidated automatically, so anything that changes the
  // light or the casters has to call `markBakedShadowsDirty` (see
  // `_onModelLoaded`).
  final _shadowCatcher = ShadowCatcherMaterial(
    mode: ShadowCatcherMode.baked,
    softness: 0.35,
    // Screen-space ambient occlusion is off (`Scene.ambientOcclusion` is
    // disabled by default) so this term cannot contribute anything. Zero it
    // rather than leaving a value that reads as if it were doing something.
    aoStrength: 0,
    fadeStart: _catcherFadeStart,
    fadeEnd: _catcherFadeEnd,
  );

  // The scene has no ongoing animation of its own (the car sits still; only
  // the camera moves, and only in response to input), so it does not need
  // SceneView's default every-frame-forever ticking. Rendering only while
  // the user is actually interacting (plus a short settle tail) keeps this
  // widget from taxing the shared UI/raster thread when idle, which matters
  // since that thread's budget is shared with the rest of the app.
  bool _ticking = false;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _orbit = OrbitCameraController(
      azimuth: -0.4,
      minDistance: 1.5,
      maxDistance: 8,
    )..frame(_carBounds, margin: 1.1);
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    super.dispose();
  }

  void _onInputActivity() {
    _stopTimer?.cancel();
    _stopTimer = null;
    if (!_ticking) setState(() => _ticking = true);
  }

  void _scheduleStop() {
    _stopTimer?.cancel();
    _stopTimer = Timer(_settleDelay, () {
      if (mounted) setState(() => _ticking = false);
    });
  }

  void _onModelLoaded(Node modelRoot) {
    // Every node is a static shadow caster: the body never moves, and the
    // wheels do not turn yet either. Static casters render into the shadow
    // atlas once and are replayed from a cached tile on later frames, which
    // is the dominant per-frame shadow cost on low-power GPUs (e.g. the
    // Raspberry Pi). Marking a node dynamic again is all that a future
    // spin/steer animation needs: drop the wheel nodes from this loop.
    for (final node in modelRoot.meshNodes) {
      node.shadowStatic = true;
    }

    // The catcher's baked cache would otherwise have been filled on the
    // first rendered frame, before the model finished loading, and never
    // refreshed: a permanently car-less shadow. Re-bake now that the caster
    // exists. The `setState` also repaints the view, which the bake needs,
    // since the scene is not ticking while idle.
    if (mounted) setState(_shadowCatcher.markBakedShadowsDirty);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEDEDF0), Color(0xFFC2C2C8)],
          ),
        ),
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) => _onInputActivity(),
          onPointerMove: (_) => _onInputActivity(),
          onPointerSignal: (_) {
            _onInputActivity();
            _scheduleStop();
          },
          onPointerUp: (_) => _scheduleStop(),
          onPointerCancel: (_) => _scheduleStop(),
          child: CameraControls(
            controller: _orbit,
            autofocus: false,
            child: SceneView.declarative(
              autoTick: _ticking,
              pixelRatio: MediaQuery.devicePixelRatioOf(context) * _renderScale,
              children: [
                SceneNode(components: [CameraComponent(), _orbit]),
                SceneNode(
                  components: [
                    DirectionalLightComponent.aimed(
                      DirectionalLight(
                        intensity: 2.4,
                        castsShadow: true,
                        // The defaults (4 cascades out to 150 world units)
                        // are sized for an open world. This scene is a 4m car
                        // viewed from at most 8m away, so three of those
                        // cascades render depth passes covering nothing, and
                        // the one that matters spends its 1024px over a
                        // 150m range. One cascade over 12m puts the whole
                        // budget on the car and removes three depth passes
                        // per frame, each of which costs a tile store/load
                        // round trip through main memory on a tile-based GPU.
                        shadowCascadeCount: 1,
                        shadowMaxDistance: 12,
                        // A smooth 4-tap kernel. The default rotated Poisson
                        // disk pays a per-fragment rotation to hide the texel
                        // grid, which a single tight cascade does not need.
                        shadowFilter: DirectionalShadowFilter.bilinearPcf,
                        // `shadowSoftness` and `contactShadows` are left at
                        // their defaults (0.08 and off) on purpose. The
                        // ground shadow's softness lives on the catcher
                        // instead, where it is baked rather than filtered per
                        // frame, so this light only has to soften the car's
                        // self-shadowing. Turning contact shadows back on
                        // would pull in the whole screen-space occlusion
                        // chain (its passes run even with ambient occlusion
                        // off) to add detail that a shadow map tight enough
                        // to cover only this car already resolves.
                      ),
                      vm.Vector3(-0.4, -1, 0.5),
                    ),
                  ],
                ),
                SceneMesh(
                  position: vm.Vector3(0, 0, 0),
                  geometry: PlaneGeometry(
                    width: _catcherExtent,
                    depth: _catcherExtent,
                  ),
                  material: _shadowCatcher,
                ),
                SceneModel('assets/models/car.glb', onLoaded: _onModelLoaded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
