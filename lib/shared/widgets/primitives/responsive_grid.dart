import 'package:flutter/material.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_dimensions.dart';

/// Responsive grid layout for different screen sizes
/// Reference: docs/ui_guideline.md - Best Practices and responsiveness
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = AppSpacing.spacingM,
    this.runSpacing = AppSpacing.spacingM,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumnsForWidth(constraints.maxWidth);

        if (columns == 1) {
          return _buildSingleColumn();
        }

        return _buildMultiColumn(columns);
      },
    );
  }

  int _getColumnsForWidth(double width) {
    if (width < AppDimensions.mobileBreakpoint) {
      return mobileColumns ?? 1;
    } else if (width < AppDimensions.desktopBreakpoint) {
      return tabletColumns ?? 2;
    } else {
      return desktopColumns ?? 3;
    }
  }

  Widget _buildSingleColumn() {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: children
            .expand(
              (child) => [
                child,
                if (child != children.last) SizedBox(height: runSpacing),
              ],
            )
            .toList(),
      ),
    );
  }

  Widget _buildMultiColumn(int columns) {
    final rows = <Widget>[];

    for (int i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];

      for (int j = 0; j < columns; j++) {
        if (i + j < children.length) {
          rowChildren.add(Expanded(child: children[i + j]));
          if (j < columns - 1 && i + j + 1 < children.length) {
            rowChildren.add(SizedBox(width: spacing));
          }
        } else {
          rowChildren.add(const Expanded(child: SizedBox.shrink()));
        }
      }

      rows.add(
        Row(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: rowChildren,
        ),
      );

      if (i + columns < children.length) {
        rows.add(SizedBox(height: runSpacing));
      }
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rows,
      ),
    );
  }
}

/// Grid layout specifically for answer buttons
class AnswerGrid extends StatelessWidget {
  final List<Widget> answers;
  final EdgeInsetsGeometry? padding;

  const AnswerGrid({super.key, required this.answers, this.padding});

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      mobileColumns: 1,
      tabletColumns: 2,
      desktopColumns: 2,
      spacing: AppDimensions.answerGridSpacing,
      runSpacing: AppDimensions.answerGridSpacing,
      padding: padding ?? const EdgeInsets.all(AppSpacing.spacingM),
      children: answers,
    );
  }
}

/// Staggered grid for varied content sizes
class StaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  const StaggeredGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.spacing = AppSpacing.spacingM,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final actualColumns = _getColumnsForWidth(constraints.maxWidth);

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(actualColumns, (columnIndex) {
              return Expanded(
                child: Column(
                  children: _getColumnChildren(columnIndex, actualColumns),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  int _getColumnsForWidth(double width) {
    if (width < AppDimensions.mobileBreakpoint) {
      return 1;
    } else if (width < AppDimensions.desktopBreakpoint) {
      return columns > 2 ? 2 : columns;
    } else {
      return columns;
    }
  }

  List<Widget> _getColumnChildren(int columnIndex, int totalColumns) {
    final columnChildren = <Widget>[];

    for (int i = columnIndex; i < children.length; i += totalColumns) {
      columnChildren.add(children[i]);
      if (i + totalColumns < children.length) {
        columnChildren.add(SizedBox(height: spacing));
      }
    }

    // Add spacing between columns
    if (columnIndex < totalColumns - 1) {
      return [
        Padding(
          padding: EdgeInsets.only(right: spacing / 2),
          child: Column(children: columnChildren),
        ),
      ];
    } else {
      return [
        Padding(
          padding: EdgeInsets.only(left: spacing / 2),
          child: Column(children: columnChildren),
        ),
      ];
    }
  }
}

/// Adaptive container that adjusts to screen size
class AdaptiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final EdgeInsetsGeometry? padding;
  final bool centerContent;

  const AdaptiveContainer({
    super.key,
    required this.child,
    this.mobileWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.padding,
    this.centerContent = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = _getWidthForScreenSize(constraints.maxWidth);

        Widget content = Container(
          width: width,
          padding: padding,
          child: child,
        );

        if (centerContent) {
          content = Center(child: content);
        }

        return content;
      },
    );
  }

  double? _getWidthForScreenSize(double screenWidth) {
    if (screenWidth < AppDimensions.mobileBreakpoint) {
      return mobileWidth ?? screenWidth;
    } else if (screenWidth < AppDimensions.desktopBreakpoint) {
      return tabletWidth ?? AppDimensions.maxContentWidth;
    } else {
      return desktopWidth ?? AppDimensions.maxContentWidth;
    }
  }
}

/// Responsive wrap layout for dynamic content
class ResponsiveWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrap({
    super.key,
    required this.children,
    this.spacing = AppSpacing.spacingM,
    this.runSpacing = AppSpacing.spacingM,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: alignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      ),
    );
  }
}

/// Masonry-style layout for Pinterest-like grids
class MasonryGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  const MasonryGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.spacing = AppSpacing.spacingM,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final actualColumns = _getColumnsForWidth(constraints.maxWidth);
        final columnWidths = List.generate(
          actualColumns,
          (index) =>
              (constraints.maxWidth - (actualColumns - 1) * spacing) /
              actualColumns,
        );

        return Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:
                List.generate(actualColumns, (columnIndex) {
                  return SizedBox(
                    width: columnWidths[columnIndex],
                    child: Column(
                      children: _getColumnChildren(columnIndex, actualColumns),
                    ),
                  );
                }).expand((column) sync* {
                  yield column;
                  if (column != children.last) {
                    yield SizedBox(width: spacing);
                  }
                }).toList(),
          ),
        );
      },
    );
  }

  int _getColumnsForWidth(double width) {
    if (width < AppDimensions.mobileBreakpoint) {
      return 1;
    } else if (width < AppDimensions.desktopBreakpoint) {
      return columns > 2 ? 2 : columns;
    } else {
      return columns;
    }
  }

  List<Widget> _getColumnChildren(int columnIndex, int totalColumns) {
    final columnChildren = <Widget>[];

    for (int i = columnIndex; i < children.length; i += totalColumns) {
      if (i > columnIndex) {
        columnChildren.add(SizedBox(height: spacing));
      }
      columnChildren.add(children[i]);
    }

    return columnChildren;
  }
}
