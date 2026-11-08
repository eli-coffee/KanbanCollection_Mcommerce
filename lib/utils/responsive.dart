import 'package:flutter/material.dart';

class Responsive {
  static const double maxContentWidth = 1200;
  static const double railBreakpoint = 800; // side rail instead of bottom bar
}

/// Centers its child and stops it from stretching past [maxWidth].
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Alignment alignment;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}