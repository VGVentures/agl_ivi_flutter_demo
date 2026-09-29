import 'package:agl_ui/agl_ui.dart';

/// {@template app_grid_item}
/// A single placement within an [AppGrid].
///
/// Positions are zero-based. An item occupies the block of cells starting at
/// ([column], [row]) and extending [columnSpan] columns and [rowSpan] rows.
/// {@endtemplate}
class AppGridItem {
  /// {@macro app_grid_item}
  const AppGridItem({
    required this.child,
    required this.column,
    required this.row,
    this.columnSpan = 1,
    this.rowSpan = 1,
  }) : assert(column >= 0, 'column must be >= 0'),
       assert(row >= 0, 'row must be >= 0'),
       assert(columnSpan >= 1, 'columnSpan must be >= 1'),
       assert(rowSpan >= 1, 'rowSpan must be >= 1');

  /// The widget rendered inside the cell(s).
  final Widget child;

  /// Zero-based column index of the top-left cell.
  final int column;

  /// Zero-based row index of the top-left cell.
  final int row;

  /// Number of columns this item spans.
  final int columnSpan;

  /// Number of rows this item spans.
  final int rowSpan;
}

/// {@template app_grid}
/// A non-scrollable grid that fills the space it is given, divided into
/// [columns] x [rows] equally sized cells.
///
/// Each [AppGridItem] is placed at an explicit position and may span multiple
/// cells. Because it relies on the incoming constraints, [AppGrid] must be
/// given bounded width and height (for example inside an [Expanded],
/// [SizedBox], or a [Scaffold] body).
/// {@endtemplate}
class AppGrid extends StatelessWidget {
  /// {@macro app_grid}
  const AppGrid({
    required this.columns,
    required this.rows,
    required this.items,
    this.spacing = 0,
    super.key,
  }) : assert(columns >= 1, 'columns must be >= 1'),
       assert(rows >= 1, 'rows must be >= 1'),
       assert(spacing >= 0, 'spacing must be >= 0');

  /// The number of columns the grid is divided into.
  final int columns;

  /// The number of rows the grid is divided into.
  final int rows;

  /// The widgets to place within the grid.
  final List<AppGridItem> items;

  /// The gap between adjacent cells, in logical pixels.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final cellHeight =
            (constraints.maxHeight - spacing * (rows - 1)) / rows;

        return Stack(
          children: [
            for (final item in items)
              Positioned(
                left: item.column * (cellWidth + spacing),
                top: item.row * (cellHeight + spacing),
                width:
                    item.columnSpan * cellWidth +
                    (item.columnSpan - 1) * spacing,
                height:
                    item.rowSpan * cellHeight + (item.rowSpan - 1) * spacing,
                child: item.child,
              ),
          ],
        );
      },
    );
  }
}
