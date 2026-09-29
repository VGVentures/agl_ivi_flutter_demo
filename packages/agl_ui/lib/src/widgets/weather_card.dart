import 'package:agl_ui/agl_ui.dart';

/// How the app draws one kind of weather.
///
/// The design system's own vocabulary for the sky, deliberately shorter
/// than any forecast API's: a caller maps whatever codes its source reports
/// onto these, and gets one icon and one label back that match every other
/// place weather is shown.
enum WeatherTreatment {
  sunny(
    label: 'CLEAR',
    icon: AppIcons.weatherClear,
    watermark: 'sun_dotted',
  ),
  partlyCloudy(
    label: 'PARTLY CLOUDY',
    icon: AppIcons.weatherPartlyCloudy,
    watermark: 'cloud_sun_dotted',
  ),
  cloudy(
    label: 'CLOUDY',
    icon: AppIcons.weatherCloudy,
    watermark: 'cloud_dotted',
  ),
  foggy(
    label: 'FOG',
    icon: AppIcons.weatherFoggy,
    watermark: 'fog_dotted',
  ),
  drizzle(
    label: 'DRIZZLE',
    icon: AppIcons.weatherDrizzle,
    watermark: 'drizzle_dotted',
  ),
  rainy(
    label: 'RAIN',
    icon: AppIcons.weatherRainy,
    watermark: 'rain_dotted',
  ),
  snowy(
    label: 'SNOW',
    icon: AppIcons.weatherSnowy,
    watermark: 'snow_dotted',
  ),
  stormy(
    label: 'STORMS',
    icon: AppIcons.weatherStormy,
    watermark: 'storm_dotted',
  );

  const WeatherTreatment({
    required this.label,
    required this.icon,
    required String watermark,
  }) : watermarkAsset = 'packages/agl_ui/assets/$watermark.svg';

  /// The condition written out, for the one place on a panel that names it.
  final String label;

  /// The glyph that stands for it everywhere else.
  final AppIconData icon;

  /// The dotted outline of this condition, which [WeatherCard] washes
  /// behind itself.
  ///
  /// Kept apart from [icon] because the two are drawn in different
  /// languages: the icon is a solid glyph sized for a list, the watermark a
  /// widely spaced dotted outline that only reads at card scale.
  final String watermarkAsset;
}

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    required this.city,
    required this.temperature,
    required this.temperatureUnit,
    required this.weatherTreatment,
    super.key,
  });

  /// The placeholder standing in for a reading that has not arrived yet.
  ///
  /// The card is laid out identically with or without one, so a reading
  /// landing changes the number and nothing else — no spinner, no shuffle.
  static const _noReading = '—';

  /// How long the wash behind the card takes to change condition.
  static const _watermarkFade = Duration(milliseconds: 400);

  final String city;

  /// The reading in whole degrees, or `null` while none has been taken.
  final int? temperature;

  final TemperatureUnit temperatureUnit;

  /// How the sky is drawn, or `null` while nothing is known about it.
  final WeatherTreatment? weatherTreatment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: context.appCardTheme.weather,
      title: city,
      background: Align(
        alignment: AlignmentGeometry.bottomRight,
        // Crossfaded rather than swapped, so the wash follows a reading
        // landing or a change of city without the corner of the card
        // flicking from one shape to another.
        child: AnimatedSwitcher(
          duration: _watermarkFade,
          child: weatherTreatment == null
              // Nothing is known about the sky yet, so the card claims
              // nothing about it.
              ? const SizedBox.shrink()
              : SvgPicture.asset(
                  weatherTreatment!.watermarkAsset,
                  key: ValueKey(weatherTreatment),
                  colorFilter: const ColorFilter.mode(
                    Colors.black,
                    BlendMode.dstIn,
                  ),
                  semanticsLabel: weatherTreatment!.label,
                ),
        ),
      ),
      // Resolved in a [Builder] so the styles come from below the card's
      // foreground color override rather than from the screen behind it.
      content: Builder(
        builder: (context) {
          final ts = Theme.of(context).textTheme;
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${temperature ?? _noReading}', style: ts.displayLarge),
              // The degree mark and the scale share one column at the end
              // of the reading: the mark at the top of the number, the
              // scale on its baseline flush below. Stacked rather than set
              // in line, so the scale reads as the mark's other half
              // instead of trailing off the number.
              Stack(
                children: [
                  Text('°', style: ts.displayLarge),
                  Text(
                    temperatureUnit.toAbbr,
                    style: ts.titleLarge,
                    // Measured against the reading's own line rather than
                    // its own smaller one, which is what drops the scale
                    // onto the number's baseline instead of leaving it at
                    // the top of the column.
                    strutStyle: StrutStyle.fromTextStyle(
                      ts.displayLarge!,
                      forceStrutHeight: true,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
