import 'package:flutter/widgets.dart';
import 'package:studyu_designer_v2/theme.dart';

class BoundedContainer extends StatelessWidget {
  const BoundedContainer({
    required this.child,
    this.maxWidth = ThemeConfig.kMaxContentWidth,
    Key? key
  }) : super(key: key);

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        ),
      ],
    );
  }
}
