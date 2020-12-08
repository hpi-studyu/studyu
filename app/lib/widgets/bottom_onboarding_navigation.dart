import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BottomOnboardingNavigation extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
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
                  Text(backLabel ?? AppLocalizations.of(context).back),
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
                    Text(nextLabel ?? AppLocalizations.of(context).next),
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
