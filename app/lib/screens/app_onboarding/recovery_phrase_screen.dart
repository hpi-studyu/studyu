import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_app/widgets/onboarding_page.dart';
import 'package:studyu_app/widgets/onboarding_shell.dart';
import 'package:studyu_app/widgets/recovery_phrase_content.dart';

class RecoveryPhraseScreen extends StatefulWidget {
  final List<String>? initialPhrase;
  final bool continueToDashboard;

  const RecoveryPhraseScreen({
    super.key,
    this.initialPhrase,
    this.continueToDashboard = false,
  });

  @override
  State<RecoveryPhraseScreen> createState() => _RecoveryPhraseScreenState();
}

class _RecoveryPhraseScreenState extends State<RecoveryPhraseScreen> {
  bool _isChecked = kDebugMode;
  bool _isRevealed = false;

  @override
  void initState() {
    super.initState();
    _isRevealed = widget.continueToDashboard;
  }

  Future<void> _continueToDashboard() async {
    final subjectId = context.read<AppState>().activeSubject?.id;
    if (subjectId != null) {
      await RecoveryPhraseStorage.clearPending(subjectId);
    }
    if (!mounted) return;
    context.goNamed(RouteNames.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    final navNotifier = OnboardingNavNotifier.maybeOf(context);
    final navConfig = _buildNavigation();
    navNotifier?.register(this, '/${RouteNames.recoveryPhrase}', navConfig);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.recovery_phrase_header),
      ),
      bottomNavigationBar: navNotifier == null ? navConfig.build() : null,
      body: OnboardingPage(
        title: '',
        description: '',
        descriptionWidget: const _RecoveryPhraseInfoCard(),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: _isRevealed
            ? RecoveryPhraseContent(
                initialPhrase: widget.initialPhrase,
                isChecked: _isChecked,
                showRotation: false,
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

  OnboardingNavConfig _buildNavigation() {
    return OnboardingNavConfig(
      hideBack: widget.continueToDashboard,
      onBack: widget.continueToDashboard
          ? null
          : () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.goNamed(RouteNames.terms);
              }
            },
      onNext: _isChecked
          ? widget.continueToDashboard
                ? _continueToDashboard
                : () => context.pushNamed(RouteNames.studySelection)
          : null,
      nextLabel: widget.continueToDashboard
          ? AppLocalizations.of(context)!.continue_to_study
          : null,
      progress: OnboardingProgress.forPage(
        context.read<AppState>(),
        OnboardingStep.recovery,
      ),
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
                  Text(
                    localizations.recovery_phrase_save_hint,
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.recovery_phrase_save_warning,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
