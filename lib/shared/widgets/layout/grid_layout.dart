import 'package:flutter/material.dart';
import 'responsive_layout.dart';

/// Responsive grid layout component
/// Reference: docs/ui_guideline.md - Grid Systems
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;
  final double runSpacing;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildGrid(mobileColumns),
      tablet: _buildGrid(tabletColumns),
      desktop: _buildGrid(desktopColumns),
    );
  }

  Widget _buildGrid(int columns) {
    if (children.isEmpty) return const SizedBox.shrink();

    final rows = <Widget>[];

    for (int i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];

      for (int j = 0; j < columns && i + j < children.length; j++) {
        rowChildren.add(Expanded(child: children[i + j]));

        // Add spacing between columns (except for last column)
        if (j < columns - 1 && i + j + 1 < children.length) {
          rowChildren.add(SizedBox(width: spacing));
        }
      }

      // Fill remaining columns with empty space if needed
      while (rowChildren.length / 2 < columns) {
        if (rowChildren.isNotEmpty) {
          rowChildren.add(SizedBox(width: spacing));
        }
        rowChildren.add(const Expanded(child: SizedBox.shrink()));
      }

      rows.add(
        Row(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisAlignment: mainAxisAlignment,
          children: rowChildren,
        ),
      );

      // Add spacing between rows (except for last row)
      if (i + columns < children.length) {
        rows.add(SizedBox(height: runSpacing));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

/// Staggered grid layout for varying height items
class StaggeredGrid extends StatelessWidget {
  final List<Widget> children;
  final int columns;
  final double spacing;
  final double runSpacing;

  const StaggeredGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    final columnChildren = List.generate(columns, (index) => <Widget>[]);

    // Distribute children across columns
    for (int i = 0; i < children.length; i++) {
      columnChildren[i % columns].add(children[i]);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnChildren
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final widgets = entry.value;

            return Expanded(
              child: Column(
                children: widgets.asMap().entries.map((widgetEntry) {
                  final widgetIndex = widgetEntry.key;
                  final widget = widgetEntry.value;

                  return Column(
                    children: [
                      widget,
                      if (widgetIndex < widgets.length - 1)
                        SizedBox(height: runSpacing),
                    ],
                  );
                }).toList(),
              ),
            );
          })
          .expand(
            (widget) => [
              widget,
              if (columnChildren.indexOf(
                    columnChildren.firstWhere(
                      (element) =>
                          element ==
                          columnChildren[columnChildren.indexOf(
                            widget as List<Widget>,
                          )],
                    ),
                  ) <
                  columns - 1)
                SizedBox(width: spacing),
            ],
          )
          .where((widget) => widget is! List)
          .cast<Widget>()
          .toList(),
    );
  }
}

/// Grid item wrapper with aspect ratio control
class GridItem extends StatelessWidget {
  final Widget child;
  final double? aspectRatio;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;

  const GridItem({
    super.key,
    required this.child,
    this.aspectRatio,
    this.padding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = child;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    if (decoration != null) {
      content = Container(decoration: decoration, child: content);
    }

    if (aspectRatio != null) {
      content = AspectRatio(aspectRatio: aspectRatio!, child: content);
    }

    return content;
  }
}
