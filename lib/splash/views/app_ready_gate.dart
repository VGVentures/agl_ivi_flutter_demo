import 'dart:async';

import 'package:agl_ivi_vgv_demo/splash/views/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scene/scene.dart';

/// {@template app_ready_gate}
/// Shows [SplashScreen] over [child] until Flutter Scene's shared engine
/// resources finish loading, then cross-fades to reveal it.
///
/// [child] is deliberately not built until the splash logos are decoded and
/// painted. Mounting it earlier constructs a `Scene`, which immediately
/// starts compiling its shader bundle and saturates the CPU/raster thread on
/// low-powered hardware, leaving the logos undecoded until that work finished
/// — which is the same moment the splash was being dismissed. Once the splash
/// is up, [child] mounts and warms up behind it.
/// {@endtemplate}
class AppReadyGate extends StatefulWidget {
  const AppReadyGate({required this.child, super.key});

  final Widget child;

  @override
  State<AppReadyGate> createState() => _AppReadyGateState();
}

class _AppReadyGateState extends State<AppReadyGate> {
  // Keeps the splash up for at least this long, so it doesn't just flash on
  // hardware fast enough to warm up almost instantly.
  static const _minimumSplashDuration = Duration(seconds: 1);
  static const _fadeDuration = Duration(milliseconds: 400);

  bool _ready = false;
  bool _showChild = false;
  bool _warmupStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_warmupStarted) {
      _warmupStarted = true;
      unawaited(_warmUp());
    }
  }

  Future<void> _warmUp() async {
    // Both logos are decoded before the splash is timed, so it never shows
    // with a logo missing.
    await Future.wait([
      precacheImage(aglLogoImage, context),
      precacheImage(vgvLogoImage, context),
    ]);
    if (!mounted) return;

    // Let the splash actually make it onto the screen before anything starts
    // competing for the raster thread.
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    setState(() => _showChild = true);

    await Future.wait([
      Scene.initializeStaticResources(),
      Future<void>.delayed(_minimumSplashDuration),
    ]);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_showChild) widget.child,
        IgnorePointer(
          ignoring: _ready,
          child: AnimatedOpacity(
            opacity: _ready ? 0 : 1,
            duration: _fadeDuration,
            curve: Curves.easeOut,
            child: const SplashScreen(),
          ),
        ),
      ],
    );
  }
}
