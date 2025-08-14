import 'package:flutter/material.dart';

// ResponsiveGrid is now located in primitives/responsive_grid.dart
// This file now only contains grid utilities that complement the main ResponsiveGrid

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
