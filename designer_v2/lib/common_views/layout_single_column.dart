import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/theme.dart';

enum SingleColumnLayoutType {
  boundedWide, boundedNarrow, stretched, split,
}

class SingleColumnLayout extends StatefulWidget {
  static const defaultConstraints = BoxConstraints(
    minWidth: ThemeConfig.kMinContentWidth,
    maxWidth: ThemeConfig.kMaxContentWidth,
  );

  static const defaultConstraintsNarrow = BoxConstraints(
    minWidth: 8/12 * ThemeConfig.kMinContentWidth,
    maxWidth: 8/12 * ThemeConfig.kMaxContentWidth,
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

  static fromType({
    required SingleColumnLayoutType type,
    required Widget body,
    required BuildContext context
  }) {
    switch (type) {
      case SingleColumnLayoutType.split:
        final screenSize = MediaQuery.of(context).size;
        return SingleColumnLayout(body: body, constraints: BoxConstraints(
          minWidth: min(ThemeConfig.kMinContentWidth, screenSize.width * 0.5),
          maxWidth: min(ThemeConfig.kMaxContentWidth, screenSize.width * 0.5),
        ));
      case SingleColumnLayoutType.stretched:
        return SingleColumnLayout(body: body, constraints: null);
      case SingleColumnLayoutType.boundedWide:
        return SingleColumnLayout(body: body, constraints: defaultConstraints);
      case SingleColumnLayoutType.boundedNarrow:
        return SingleColumnLayout(body: body, constraints: defaultConstraintsNarrow);
    }
  }

  @override
  State<SingleColumnLayout> createState() => _SingleColumnLayoutState();
}

class _SingleColumnLayoutState extends State<SingleColumnLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = widget.body;

    if (widget.padding != null) {
      body = Padding(padding: widget.padding!, child: body);
    }
    if (widget.constraints != null) {
      body = Container(constraints: widget.constraints, child: body);
    }

    body = Row(
      children: [
        Flexible(
            child: Container(
              constraints: widget.constraints,
              child: body,
            )
        )
      ],
    );

    if (widget.scroll) {
      return Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
            controller: _scrollController,
            child: body
      ));
    }

    return body;
  }
}
