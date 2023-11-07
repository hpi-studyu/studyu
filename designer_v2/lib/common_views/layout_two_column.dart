import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/constrained_flexible.dart';

class TwoColumnLayout extends StatefulWidget {
  const TwoColumnLayout({
    required this.leftWidget,
    required this.rightWidget,
    this.headerWidget,
    this.dividerWidget = defaultDivider,
    this.flexLeft,
    this.flexRight = 1, // expand right column to fill available space by default
    this.constraintsLeft,
    this.constraintsRight,
    this.scrollLeft = true,
    this.scrollRight = true,
    this.paddingLeft = defaultContentPadding,
    this.paddingRight = defaultContentPadding,
    this.backgroundColorLeft,
    this.backgroundColorRight,
    this.stretchHeight = false,
    super.key,
  });

  static const VerticalDivider defaultDivider = VerticalDivider(
    width: 1,
    thickness: 1,
  );
  static const EdgeInsets defaultContentPadding = EdgeInsets.symmetric(
    horizontal: 48.0,
    vertical: 32.0,
  );
  static const EdgeInsets slimContentPadding = EdgeInsets.symmetric(
    horizontal: 32.0,
    vertical: 32.0,
  );

  final Widget leftWidget;
  final Widget rightWidget;
  final Widget? dividerWidget;
  final Widget? headerWidget;

  final int? flexLeft;
  final int? flexRight;

  final BoxConstraints? constraintsLeft;
  final BoxConstraints? constraintsRight;

  final bool scrollLeft;
  final bool scrollRight;

  final EdgeInsets? paddingLeft;
  final EdgeInsets? paddingRight;

  final Color? backgroundColorLeft;
  final Color? backgroundColorRight;

  final bool stretchHeight;

  @override
  State<TwoColumnLayout> createState() => _TwoColumnLayoutState();

  factory TwoColumnLayout.split({
    required Widget leftWidget,
    required Widget rightWidget,
    Widget? dividerWidget,
    int? flexLeft = 9,
    int? flexRight = 8,
    BoxConstraints? constraintsLeft,
    BoxConstraints? constraintsRight,
    bool scrollLeft = true,
    bool scrollRight = true,
    final EdgeInsets? paddingLeft = TwoColumnLayout.defaultContentPadding,
    final EdgeInsets? paddingRight = TwoColumnLayout.defaultContentPadding,
  }) {
    return TwoColumnLayout(
      leftWidget: leftWidget,
      rightWidget: rightWidget,
      dividerWidget: dividerWidget,
      flexLeft: flexLeft,
      flexRight: flexRight,
      constraintsLeft: constraintsLeft,
      constraintsRight: constraintsRight,
      scrollLeft: scrollLeft,
      scrollRight: scrollRight,
      paddingLeft: paddingLeft,
      paddingRight: paddingRight,
    );
  }
}

class _TwoColumnLayoutState extends State<TwoColumnLayout> {
  final ScrollController _scrollControllerLeft = ScrollController();
  final ScrollController _scrollControllerRight = ScrollController();

  @override
  void dispose() {
    _scrollControllerLeft.dispose();
    _scrollControllerRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget leftWidget = widget.leftWidget;
    Widget rightWidget = widget.rightWidget;

    if (widget.paddingLeft != null) {
      leftWidget = Padding(padding: widget.paddingLeft!, child: leftWidget);
    }
    if (widget.paddingRight != null) {
      rightWidget = Padding(padding: widget.paddingRight!, child: rightWidget);
    }

    if (widget.backgroundColorLeft != null) {
      leftWidget = Material(color: widget.backgroundColorLeft, child: leftWidget);
    }
    if (widget.backgroundColorRight != null) {
      rightWidget = Material(color: widget.backgroundColorRight, child: rightWidget);
    }

    return LayoutBuilder(builder: (context, constraints) {
      if (widget.stretchHeight) {
        leftWidget = SizedBox(
          height: constraints.maxHeight,
          child: leftWidget,
        );
        rightWidget = SizedBox(
          height: constraints.maxHeight,
          child: rightWidget,
        );
      }

      if (widget.scrollLeft) {
        leftWidget = Scrollbar(
          thumbVisibility: true,
          controller: _scrollControllerLeft,
          child: SingleChildScrollView(controller: _scrollControllerLeft, child: leftWidget),
        );
      }
      if (widget.scrollRight) {
        rightWidget = Scrollbar(
          thumbVisibility: true,
          controller: _scrollControllerRight,
          child: SingleChildScrollView(controller: _scrollControllerRight, child: rightWidget),
        );
      }

      if (!(widget.constraintsLeft != null && widget.flexLeft != null)) {
        if (widget.constraintsLeft != null) {
          leftWidget = Container(constraints: widget.constraintsLeft!, child: leftWidget);
        }
        if (widget.flexLeft != null) {
          leftWidget = Flexible(flex: widget.flexLeft!, child: leftWidget);
        }
      }

      if (!(widget.constraintsRight != null && widget.flexRight != null)) {
        if (widget.constraintsRight != null) {
          rightWidget = Container(constraints: widget.constraintsRight!, child: rightWidget);
        }
        if (widget.flexRight != null) {
          rightWidget = Flexible(flex: widget.flexRight!, child: rightWidget);
        }
      }

      if (widget.constraintsLeft != null && widget.flexLeft != null) {
        leftWidget = ConstrainedWidthFlexible(
          minWidth: widget.constraintsLeft?.minWidth ?? double.infinity,
          maxWidth: widget.constraintsLeft?.maxWidth ?? double.infinity,
          flex: widget.flexLeft!,
          flexSum: widget.flexLeft! + (widget.flexRight ?? 0),
          outerConstraints: constraints,
          child: leftWidget,
        );
      }

      if (widget.constraintsRight != null && widget.flexRight != null) {
        rightWidget = ConstrainedWidthFlexible(
          minWidth: widget.constraintsRight?.minWidth ?? double.infinity,
          maxWidth: widget.constraintsRight?.maxWidth ?? double.infinity,
          flex: widget.flexRight!,
          flexSum: widget.flexRight! + (widget.flexLeft ?? 0),
          outerConstraints: constraints,
          child: rightWidget,
        );
      }

      Widget body = Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          leftWidget,
          widget.dividerWidget ?? const SizedBox.shrink(),
          rightWidget,
        ],
      );

      if (widget.headerWidget != null) {
        body = Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            widget.headerWidget!,
            body,
          ],
        );
      }

      return body;
    });
  }
}
