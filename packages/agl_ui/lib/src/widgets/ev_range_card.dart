import 'package:agl_ui/agl_ui.dart';

class EvRangeCard extends StatelessWidget {
  const EvRangeCard({
    required this.title,
    required this.percentage,
    required this.remainingRange,
    required this.rangeUnits,
    super.key,
  });

  final String title;
  final int percentage; // 0 to 100
  final int remainingRange;
  final String rangeUnits;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: context.appCardTheme.evRange,
      title: title,
      content: TextWithUnits(text: '$remainingRange', units: rangeUnits),
    );
  }
}
