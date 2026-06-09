import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';

class BottomOnboardingNavigation extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String? backLabel;
  final String? nextLabel;
  final bool hideNext;
  final bool hideBack;
  final bool backEnabled;
  final Icon? nextIcon;
  final Icon? backIcon;
  final Widget? progress;
  final Key? backButtonKey;
  final Key? nextButtonKey;

  const BottomOnboardingNavigation({
    super.key,
    this.onNext,
    this.onBack,
    this.backLabel,
    this.nextLabel,
    this.hideNext = false,
    this.hideBack = false,
    this.backEnabled = true,
    this.nextIcon,
    this.backIcon,
    this.progress,
    this.backButtonKey,
    this.nextButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Visibility(
              visible: !hideBack,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
                key: backButtonKey,
                onPressed: backEnabled
                    ? (onBack ?? () => Navigator.pop(context))
                    : null,
                child: Row(
                  children: [
                    backIcon ?? const Icon(Icons.navigate_before),
                    Text(backLabel ?? AppLocalizations.of(context)!.back),
                  ],
                ),
              ),
            ),
            if (progress != null) ...[
              const SizedBox(width: 8),
              Expanded(child: progress!),
              const SizedBox(width: 8),
            ] else
              const Spacer(),
            Visibility(
              visible: !hideNext,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
                key: nextButtonKey,
                onPressed: onNext,
                child: Row(
                  children: [
                    Text(nextLabel ?? AppLocalizations.of(context)!.next),
                    nextIcon ?? const Icon(Icons.navigate_next),
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
