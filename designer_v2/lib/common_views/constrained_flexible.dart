import 'package:flutter/widgets.dart';

/// Taken from
/// https://stackoverflow.com/questions/56417186/specific-min-and-max-size-for-expanded-widgets-in-column
class ConstrainedWidthFlexible extends StatelessWidget {
  const ConstrainedWidthFlexible(
      {required this.minWidth,
      required this.maxWidth,
      required this.flex,
      required this.flexSum,
      required this.outerConstraints,
      required this.child,
      super.key});

  final double minWidth;
  final double maxWidth;
  final int flex;
  final int flexSum;
  final Widget child;
  final BoxConstraints outerConstraints;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
      child: SizedBox(
        width: _getWidth(outerConstraints.maxWidth),
        child: child,
      ),
    );
  }

  double _getWidth(double outerContainerWidth) {
    return outerContainerWidth * flex / flexSum;
  }
}
