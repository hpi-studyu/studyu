import 'package:flutter/widgets.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column_scroll.dart';

class SingleColumnScrollLayout extends StatelessWidget {
  const SingleColumnScrollLayout({
    required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TwoColumnLayoutLeftFixedBodyScroll(
      bodyWidget: child,
      leftWidget: const SizedBox.shrink(),
      dividerWidget: const SizedBox.shrink(),
    );
  }
}
