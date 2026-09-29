import 'package:agl_ui/agl_ui.dart';

class TextWithUnits extends StatelessWidget {
  const TextWithUnits({required this.text, required this.units, super.key});

  final String text;
  final String units;

  @override
  Widget build(BuildContext context) {
    final ts = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          text,
          style: ts.displayLarge,
        ),
        SizedBox(width: context.appSpacing.sm),
        Text(
          units,
          style: ts.titleSmall,
        ),
      ],
    );
  }
}
