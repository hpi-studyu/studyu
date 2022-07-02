import 'package:flutter/material.dart';

class FixedSideScrollBodyLayout extends StatefulWidget {
  final Widget sideDrawerWidget;
  final Widget mainContentWidget;
  final Widget? dividerWidget;

  final double mainContentPaddingHorizontal;
  final double mainContentPaddingVertical;

  static const VerticalDivider defaultDivider = VerticalDivider(
    width: 1,
    thickness: 1,
  );

  const FixedSideScrollBodyLayout({
    Key? key,
    required this.sideDrawerWidget,
    required this.mainContentWidget,
    this.mainContentPaddingHorizontal = 48.0,
    this.mainContentPaddingVertical = 32.0,
    Widget? this.dividerWidget,
  }) : super(key: key);

  @override
  State<FixedSideScrollBodyLayout> createState() => _FixedSideScrollBodyLayoutState();
}

class _FixedSideScrollBodyLayoutState extends State<FixedSideScrollBodyLayout> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.sideDrawerWidget,
        widget.dividerWidget ?? FixedSideScrollBodyLayout.defaultDivider,
        Expanded(
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: widget.mainContentPaddingVertical,
                      horizontal: widget.mainContentPaddingHorizontal
                  ),
                  child: widget.mainContentWidget,
                ),
              ),
            ),
        ),
      ],
    );
  }
}
