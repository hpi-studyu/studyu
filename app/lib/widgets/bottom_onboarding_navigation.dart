import 'package:flutter/material.dart';

import '../util/localization.dart';

class BottomOnboardingNavigation extends StatelessWidget {
  final Function onBack;
  final Function onNext;
  final String backLabel;
  final String nextLabel;
  final bool hideNext;
  final Icon nextIcon;
  final Icon backIcon;

  const BottomOnboardingNavigation(
      {Key key,
      this.onNext,
      this.onBack,
      this.backLabel,
      this.nextLabel,
      this.hideNext = false,
      this.nextIcon,
      this.backIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          FlatButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            child: Row(
              children: [
                backIcon ?? Icon(Icons.navigate_before),
                Text(backLabel ?? Nof1Localizations.of(context).translate('back')),
              ],
            ),
          ),
          Spacer(),
          if (!hideNext)
            FlatButton(
              onPressed: onNext,
              child: Row(
                children: [
                  Text(nextLabel ?? Nof1Localizations.of(context).translate('next')),
                  nextIcon ?? Icon(Icons.navigate_next),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
