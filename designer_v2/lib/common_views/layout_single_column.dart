import 'package:flutter/widgets.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/theme.dart';

enum SingleColumnLayoutType {
  bounded, stretched, split,
}

class SingleColumnLayout extends StatelessWidget {
  static const defaultConstraints = BoxConstraints(
    minWidth: ThemeConfig.kMinContentWidth,
    maxWidth: ThemeConfig.kMaxContentWidth,
  );

  const SingleColumnLayout({
    required this.body,
    this.constraints = defaultConstraints,
    this.scroll = true,
    this.padding = TwoColumnLayout.defaultContentPadding,
    Key? key
  }) : super(key: key);

  final Widget body;
  final BoxConstraints? constraints;
  final bool scroll;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return TwoColumnLayout(
      leftWidget: const SizedBox.shrink(),
      rightWidget: body,
      dividerWidget: null,
      flexLeft: null,
      flexRight: 1,
      constraintsLeft: null,
      constraintsRight: constraints,
      scrollLeft: false,
      scrollRight: scroll,
      paddingLeft: null,
      paddingRight: padding,
    );
  }

  static fromType({required SingleColumnLayoutType type, required Widget body}) {
    switch (type) {
      case SingleColumnLayoutType.split:
        return TwoColumnLayout.split(
          leftWidget: body,
          rightWidget: Container(),
          dividerWidget: null,
          constraintsLeft: const BoxConstraints(
              minWidth: ThemeConfig.kMinContentWidth,
              maxWidth: ThemeConfig.kMaxContentWidth
          ),
        );
      case SingleColumnLayoutType.stretched:
        return SingleColumnLayout(body: body, constraints: null);
      case SingleColumnLayoutType.bounded:
        return SingleColumnLayout(body: body);
    }
  }
}
