import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/spacing.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Padding(
        padding: const EdgeInsets.all(StudyUSpacing.space2),
        child: Row(
          children: [
            Visibility(
              visible: !hideBack,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
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
              const SizedBox(width: StudyUSpacing.space2),
              Expanded(child: progress!),
              const SizedBox(width: StudyUSpacing.space2),
            ] else
              const Spacer(),
            Visibility(
              visible: !hideNext,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: TextButton(
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
