import 'package:agl_ui/agl_ui.dart';

/// {@template app_theme}
/// Composes [ThemeData] with [ColorScheme.fromSeed] and custom
/// [ThemeExtension]s for light and dark variants.
/// {@endtemplate}
class AppTheme {
  /// The light [ThemeData].
  static ThemeData get rainbow {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      iconTheme: const IconThemeData(color: Color(0xFF000000)),
      fontFamily: 'Geist Mono',
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFff7a01)),
      extensions: const [
        AppSpacing(),
        AppTextStyles(),
        AppAccentTheme(color: Color(0xFF34C759)),
        AppCardTheme(
          calendar: AppCardStyle(
            // The tile's green is an accent, not a surface: at panel size
            // it leaves the agenda nothing to sit on, so the overlay
            // deepens it to a shade of the same hue instead.
            background: BoxDecoration(color: Color(0xFF27EB63)),
            overlayBackground: BoxDecoration(color: Color(0xFF0E2A1A)),
          ),
          weather: AppCardStyle(
            // Yellow is the loudest accent on the home screen: filling a
            // whole panel with it leaves the forecast nothing to sit on,
            // so the overlay deepens it to a shade of the same hue and
            // picks its labels out in the card's own yellow.
            background: BoxDecoration(color: Color(0xFFFFCC00)),
            overlayBackground: BoxDecoration(color: Color(0xFF2B2200)),
            accentColor: Color(0xFFFFCC00),
          ),
          evRange: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF0C5CFF)),
            foregroundColor: Color(0xFFFFFFFF),
          ),
          settings: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF000000)),
            foregroundColor: Color(0xFFFFFFFF),
          ),
        ),
        ProfileStyleCard(
          backgroundColor: Color(0xFF000000),
          borderRadius: 30,
        ),
        PhoneStyleCard(
          backgroundColor: Color(0xFF000000),
          borderRadius: 30,
        ),
        // Each drive mode is painted in its own two-stop gradient, so which
        // one the car is in reads from the color before the name is read.
        // Eco keeps the gradient the card was designed in; the other four
        // are pitched around it — cool for Comfort and Snow, hot for Sport,
        // violet for the one the driver built. All five open onto the same
        // deepened surface, which is the only thing a panel of dense
        // controls reads against.
        DriveModeStyleCard(
          comfort: AppCardStyle(
            background: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8FD3F4), Color(0xFF84A9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            overlayBackground: _driveModeOverlaySurface,
            accentColor: Color(0xFF8FD3F4),
            borderRadius: 30,
          ),
          eco: AppCardStyle(
            background: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFA845), Color(0xFFFC77EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            overlayBackground: _driveModeOverlaySurface,
            accentColor: Color(0xFFFFA845),
            borderRadius: 30,
          ),
          sport: AppCardStyle(
            background: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF3B30), Color(0xFF8E0038)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            overlayBackground: _driveModeOverlaySurface,
            foregroundColor: Color(0xFFFFFFFF),
            accentColor: Color(0xFFFF6B5E),
            borderRadius: 30,
          ),
          snow: AppCardStyle(
            background: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB9E6FF), Color(0xFF5FA8E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            overlayBackground: _driveModeOverlaySurface,
            accentColor: Color(0xFFB9E6FF),
            borderRadius: 30,
          ),
          custom: AppCardStyle(
            background: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFB39DFF), Color(0xFF6C5CE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            overlayBackground: _driveModeOverlaySurface,
            foregroundColor: Color(0xFFFFFFFF),
            accentColor: Color(0xFFB39DFF),
            borderRadius: 30,
          ),
        ),
        MusicPlayerStyleCard(
          backgroundColor: Color(0xFFCEEBF1),
          accentColor: Color(0xFF000000),
          iconColor: Color(0xFF000000),
          borderRadius: 30,
        ),
        BoostCardStyle(backgroundColor: Color(0xFFD0F1DA), borderRadius: 30),
        // The stack's own grey is a surface at tile size and a fog at
        // panel size, so the overlay deepens to the near-black the
        // drive mode panel settles on and picks its labels out in the EV
        // Range card's blue — the section that leads the panel.
        TripEfficiencyCardStyle(
          backgroundColor: Color(0xFFBABABA),
          barColor: Color(0xFF000000),
          borderRadius: 30,
          overlayBackgroundColor: Color(0xFF14161F),
          accentColor: Color(0xFF4C8CFF),
        ),
      ],
    );
  }

  /// The Earthy [ThemeData], styled after the "Home V3" Figma design.
  static ThemeData get earthy {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFF282421),
      iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
      fontFamily: 'Geist Mono',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF7A01),
        brightness: Brightness.dark,
      ),
      // Reuses rainbow's resolved TextTheme so both themes share the exact
      // same font, sizes and weights — the seeded ColorScheme's auto-derived
      // text color reads as a warm off-white, so it's repinned to white here
      // instead of left to Material's default.
      textTheme: rainbow.textTheme.apply(
        bodyColor: const Color(0xFFFFFFFF),
        displayColor: const Color(0xFFFFFFFF),
      ),
      extensions: const [
        AppSpacing(),
        AppTextStyles(),
        AppAccentTheme(color: Color(0xFFFF7A01)),
        AppCardTheme(
          calendar: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF3B3630)),
            foregroundColor: Color(0xFFFFFFFF),
          ),
          weather: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF595959)),
            foregroundColor: Color(0xFFFFFFFF),
          ),
          evRange: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF595959)),
            foregroundColor: Color(0xFFFFFFFF),
          ),
          settings: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF181818)),
            foregroundColor: Color(0xFFFFFFFF),
          ),
        ),
        ProfileStyleCard(
          backgroundColor: Color(0x66676767),
          borderRadius: 30,
        ),
        PhoneStyleCard(
          backgroundColor: Color(0x66676767),
          borderRadius: 30,
        ),
        // Earthy paints its cards flat rather than in gradients, so the
        // modes are told apart by hue alone: Eco keeps the olive the card
        // was designed in, and the other four are muted to sit beside it.
        DriveModeStyleCard(
          comfort: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF6B6259)),
            overlayBackground: _driveModeOverlaySurfaceEarthy,
            borderRadius: 30,
          ),
          eco: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF7B886E)),
            overlayBackground: _driveModeOverlaySurfaceEarthy,
            borderRadius: 30,
          ),
          sport: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF8A4A32)),
            overlayBackground: _driveModeOverlaySurfaceEarthy,
            borderRadius: 30,
          ),
          snow: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF5E7481)),
            overlayBackground: _driveModeOverlaySurfaceEarthy,
            borderRadius: 30,
          ),
          custom: AppCardStyle(
            background: BoxDecoration(color: Color(0xFF6A5F7A)),
            overlayBackground: _driveModeOverlaySurfaceEarthy,
            borderRadius: 30,
          ),
        ),
        MusicPlayerStyleCard(
          backgroundColor: Color(0xFF181818),
          accentColor: Color(0xFFFF7A01),
          iconColor: Color(0xFFFFFFFF),
          borderRadius: 30,
        ),
        BoostCardStyle(backgroundColor: Color(0xFF595959), borderRadius: 30),
        // Earthy's cards are already dark, so the panel only drops a shade
        // to separate itself from the card behind it, and leaves the
        // labels to the theme's own accent — the color the bars are
        // already drawn in.
        TripEfficiencyCardStyle(
          backgroundColor: Color(0xFF3B3630),
          barColor: Color(0xFFFF7A01),
          borderRadius: 30,
          overlayBackgroundColor: Color(0xFF221F1C),
        ),
      ],
    );
  }

  /// The surface every drive mode's panel settles on in [rainbow].
  ///
  /// Shared rather than one per mode: the panel carries a list, a hero and
  /// five adjustable bars, and repainting all of it on every selection would
  /// be exhausting to flick through. The mode comes through in
  /// [AppCardStyle.accentColor] instead.
  static const _driveModeOverlaySurface = BoxDecoration(
    color: Color(0xFF17161F),
  );

  /// [_driveModeOverlaySurface]'s counterpart in [earthy], a shade off the
  /// theme's own background rather than the near-black rainbow deepens to.
  static const _driveModeOverlaySurfaceEarthy = BoxDecoration(
    color: Color(0xFF221F1C),
  );

  /// Resolves the [ThemeData] for [id].
  static ThemeData themeFor(AppThemeId id) => switch (id) {
    AppThemeId.rainbow => rainbow,
    AppThemeId.earthy => earthy,
  };
}
