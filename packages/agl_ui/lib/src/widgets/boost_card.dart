import 'dart:ui';

import 'package:agl_ui/agl_ui.dart';

class BoostCardStyle extends ThemeExtension<BoostCardStyle> {
  const BoostCardStyle({
    required this.backgroundColor,
    required this.borderRadius,
  });

  final Color backgroundColor;
  final double borderRadius;

  @override
  BoostCardStyle copyWith({
    Color? backgroundColor,
    double? borderRadius,
  }) {
    return BoostCardStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  BoostCardStyle lerp(
    covariant ThemeExtension<BoostCardStyle>? other,
    double t,
  ) {
    if (other is! BoostCardStyle) {
      return this;
    }
    return BoostCardStyle(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t)!,
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t)!,
    );
  }
}

class BoostCard extends StatelessWidget {
  const BoostCard({
    required this.title,
    required this.pressure,
    required this.units,
    super.key,
  });

  final String title;
  final double pressure;
  final String units;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    final style = context.boostCardStyle;
    return Card(
      color: style.backgroundColor,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(style.borderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(context.appSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: ts.titleMedium,
            ),
            TextWithUnits(text: '$pressure', units: units),
          ],
        ),
      ),
    );
  }
}
