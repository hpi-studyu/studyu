import 'package:flutter/material.dart';

class TwoColumnLayoutLeftFixedBodyScroll extends StatefulWidget {
  final Widget leftWidget;
  final Widget bodyWidget;
  final Widget? dividerWidget;

  final double bodyPaddingHorizontal;
  final double bodyPaddingVertical;

  static const VerticalDivider defaultDivider = VerticalDivider(
    width: 1,
    thickness: 1,
  );

  const TwoColumnLayoutLeftFixedBodyScroll({
    Key? key,
    required this.leftWidget,
    required this.bodyWidget,
    this.bodyPaddingHorizontal = 48.0,
    this.bodyPaddingVertical = 32.0,
    Widget? this.dividerWidget,
  }) : super(key: key);

  @override
  State<TwoColumnLayoutLeftFixedBodyScroll> createState() => _TwoColumnLayoutLeftFixedBodyScrollState();
}

class _TwoColumnLayoutLeftFixedBodyScrollState
    extends State<TwoColumnLayoutLeftFixedBodyScroll> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.leftWidget,
        widget.dividerWidget ?? TwoColumnLayoutLeftFixedBodyScroll.defaultDivider,
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: widget.bodyPaddingVertical,
                      horizontal: widget.bodyPaddingHorizontal
                  ),
                  child: widget.bodyWidget,
                ),
              ),
            ),
        ),
      ],
    );
  }
}
