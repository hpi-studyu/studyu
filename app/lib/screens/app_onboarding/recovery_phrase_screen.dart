import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/onboarding_page.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  final List<String>? initialPhrase;

  const RecoveryPhraseScreen({super.key, this.initialPhrase});

  @override
  State<RecoveryPhraseScreen> createState() => _RecoveryPhraseScreenState();
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  bool _isChecked = false;
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnboardingPage(
        title: AppLocalizations.of(context)!.recovery_phrase_header,
        description: '',
        descriptionWidget: const _RecoveryPhraseInfoCard(),
        bottomNavigationBar: _buildNavigation(),
        child: _isRevealed
            ? RecoveryPhraseContent(
                initialPhrase: widget.initialPhrase,
                isChecked: _isChecked,
                onCheckedChanged: (value) {
                  setState(() {
                    _isChecked = value ?? false;
                  });
                },
              )
            : Center(
                child: FilledButton(
                  onPressed: () => setState(() => _isRevealed = true),
                  child: Text(
                    AppLocalizations.of(context)!.show_recovery_phrase,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNavigation() {
    return BottomOnboardingNavigation(
      onBack: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goNamed(RouteNames.terms);
        }
      },
      onNext: _isChecked
          ? () {
              context.pushNamed(RouteNames.studySelection);
            }
          : null,
    );
  }
}

class _RecoveryPhraseInfoCard extends StatelessWidget {
  const _RecoveryPhraseInfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = AppLocalizations.of(context)!;
    final hint = localizations.recovery_phrase_save_hint;
    final warning = localizations.recovery_phrase_save_warning;
    final warningIndex = hint.indexOf(warning);
    final mainText = warningIndex == -1
        ? hint
        : hint.substring(0, warningIndex).trim();
    final warningText = warningIndex == -1
        ? null
        : hint.substring(warningIndex);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_outline, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mainText, style: textTheme.bodyMedium),
                  if (warningText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      warningText,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
