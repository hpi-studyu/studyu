import 'package:flutter/material.dart';

class SidenavLayout extends StatelessWidget {
  final Widget sideDrawerWidget;
  final Widget mainContentWidget;
  final Widget? dividerWidget;

  static const mainContentPaddingHorizontal = 48.0;
  static const mainContentPaddingVertical = 32.0;

  static const VerticalDivider defaultDivider = VerticalDivider(
    width: 1,
    thickness: 1,
  );

  const SidenavLayout({
    Key? key,
    required this.sideDrawerWidget,
    required this.mainContentWidget,
    Widget? this.dividerWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        sideDrawerWidget,
        dividerWidget ?? SidenavLayout.defaultDivider,
        Expanded(
          child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: mainContentPaddingVertical,
                  horizontal: mainContentPaddingHorizontal),
              child: mainContentWidget),
        ),
      ],
    );
  }
}
