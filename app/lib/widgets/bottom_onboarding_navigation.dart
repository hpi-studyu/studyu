import 'package:flutter/material.dart';
import 'package:studyou_core/util/localization.dart';

class BottomOnboardingNavigation extends StatelessWidget {
  final Function onBack;
  final Function onNext;
  final String backLabel;
  final String nextLabel;
  final bool hideNext;
  final Icon nextIcon;
  final Icon backIcon;
  final Widget progress;

  const BottomOnboardingNavigation(
      {Key key,
      this.onNext,
      this.onBack,
      this.backLabel,
      this.nextLabel,
      this.hideNext = false,
      this.nextIcon,
      this.backIcon,
      this.progress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
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
            if (progress != null) ...[SizedBox(width: 8), Expanded(child: progress), SizedBox(width: 8)] else Spacer(),
            Visibility(
              visible: !hideNext,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: FlatButton(
                onPressed: onNext,
                child: Row(
                  children: [
                    Text(nextLabel ?? Nof1Localizations.of(context).translate('next')),
                    nextIcon ?? Icon(Icons.navigate_next),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
