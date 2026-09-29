import 'package:agl_ui/agl_ui.dart';
import 'package:flutter/gestures.dart';

class VerticalScrollableStackCard extends StatefulWidget {
  const VerticalScrollableStackCard({required this.children, super.key});

  final List<Widget> children;

  @override
  State<VerticalScrollableStackCard> createState() =>
      _VerticalScrollableStackCardState();
}

class _VerticalScrollableStackCardState
    extends State<VerticalScrollableStackCard> {
  late final PageController controller;

  @override
  void initState() {
    super.initState();
    controller = PageController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.stylus,
              PointerDeviceKind.trackpad,
            },
          ),
          child: PageView(
            scrollDirection: Axis.vertical,
            controller: controller,
            children: widget.children,
          ),
        ),
        Positioned(
          top: 0,
          bottom: 0,
          right: context.appSpacing.sm,
          child: Center(
            child: IgnorePointer(
              child: PageIndicator(
                controller: controller,
                total: widget.children.length,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A vertical page indicator that follows [controller] with an expanding dots
/// effect: the dot of the current page is [expansionFactor] times taller than
/// the others, and that extra height transfers to the next dot as the page
/// scrolls, so the indicator tracks the drag instead of snapping on settle.
class PageIndicator extends StatelessWidget {
  const PageIndicator({
    required this.controller,
    required this.total,
    this.dotSize = 8,
    this.expansionFactor = 3,
    this.spacing = 6,
    this.activeColor,
    this.inactiveColor,
    super.key,
  });

  /// The controller of the [PageView] this indicator represents.
  final PageController controller;

  /// The number of pages.
  final int total;

  /// The width of every dot, and the height of an inactive one.
  final double dotSize;

  /// How much taller the active dot is compared to an inactive one.
  final double expansionFactor;

  /// The gap between two dots.
  final double spacing;

  /// The color of the active dot. Defaults to `colorScheme.onSurface`.
  final Color? activeColor;

  /// The color of the inactive dots. Defaults to a faded [activeColor].
  final Color? inactiveColor;

  /// The current page as a fraction, e.g. `1.4` while scrolling from the
  /// second page to the third.
  ///
  /// [PageController.page] is null until the [PageView] has been laid out, so
  /// fall back to the initial page for the first frame.
  double _page() {
    if (!controller.hasClients) return controller.initialPage.toDouble();
    return controller.page ?? controller.initialPage.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    if (total < 2) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final active = activeColor ?? colorScheme.onSurface;
    final inactive = inactiveColor ?? active.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = _page().clamp(0.0, total - 1.0);
        final current = page.floor();
        // How far the transition to the next page has progressed, 0 to 1.
        final progress = page - current;

        // How "active" a dot is, from 0 to 1. The current dot hands its share
        // over to the next one as the page scrolls, so those two always add up
        // to 1 and every other dot sits at 0.
        double activeness(int index) {
          if (index == current) return 1 - progress;
          if (index == current + 1) return progress;
          return 0;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < total; index++) ...[
              if (index > 0) SizedBox(height: spacing),
              _Dot(
                width: dotSize,
                height:
                    dotSize * (1 + (expansionFactor - 1) * activeness(index)),
                color: Color.lerp(inactive, active, activeness(index))!,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.width,
    required this.height,
    required this.color,
  });

  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(width / 2),
      ),
    );
  }
}
