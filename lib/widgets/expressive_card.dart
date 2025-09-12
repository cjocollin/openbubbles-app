import 'package:flutter/material.dart';

class ExpressiveCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onHighlightChanged;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const ExpressiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.onHighlightChanged,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Material(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          onHighlightChanged: onHighlightChanged,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
