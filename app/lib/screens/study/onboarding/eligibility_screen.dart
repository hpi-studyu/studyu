import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';

import '../../../widgets/bottom_onboarding_navigation.dart';
import '../../../widgets/questionnaire/questionnaire_widget.dart';
import 'onboarding_progress.dart';

class EligibilityResult {
  final bool eligible;
  final QuestionnaireState answers;
  final EligibilityCriterion? firstFailed;

  EligibilityResult(this.answers, {required this.eligible, this.firstFailed});
}

class EligibilityScreen extends StatefulWidget {
  final Study? study;

  static MaterialPageRoute<EligibilityResult> routeFor({required Study? study}) => MaterialPageRoute(
        builder: (_) => EligibilityScreen(study: study),
        settings: const RouteSettings(name: '/eligibilityCheck'),
      );

  const EligibilityScreen({required this.study, super.key});

  @override
  State<StatefulWidget> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  EligibilityResult? activeResult;

  @override
  void initState() {
    super.initState();
    activeResult = null;
  }

  void _invalidateResponse(QuestionnaireState qs) {
    setState(() {
      activeResult = null;
    });
  }

  bool _checkContinuation(QuestionnaireState qs) {
    final criteria = widget.study!.eligibilityCriteria;
    final failingResult = criteria.firstWhereOrNull((element) => element.isViolated(qs));
    if (failingResult == null) return true;
    setState(() {
      activeResult = EligibilityResult(qs, eligible: false, firstFailed: failingResult);
    });
    return false;
  }

  void _evaluateResponse(QuestionnaireState qs) {
    final criteria = widget.study!.eligibilityCriteria;
    setState(() {
      final conditionResult = criteria.every((criterion) => criterion.isSatisfied(qs));
      if (conditionResult) {
        activeResult = EligibilityResult(qs, eligible: conditionResult);
      } else {
        final firstFailed = criteria.firstWhere((criterion) => criterion.isViolated(qs));
        activeResult = EligibilityResult(qs, eligible: conditionResult, firstFailed: firstFailed);
      }
    });
  }

  void _finish() {
    Navigator.pop(context, activeResult);
  }

  Widget _constructPassBanner() => MaterialBanner(
        leading: Icon(
          MdiIcons.checkboxMarkedCircle,
          color: Colors.green,
          size: 32,
        ),
        content: Text(AppLocalizations.of(context)!.eligible_yes, style: Theme.of(context).textTheme.titleMedium),
        actions: [Container()],
        forceActionsBelow: true,
        backgroundColor: Colors.green[50],
      );

  Widget _constructFailBanner() => MaterialBanner(
        leading: Icon(
          MdiIcons.closeCircle,
          color: Colors.red,
          size: 32,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.eligible_no, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            if (activeResult?.firstFailed?.reason != null)
              Text(activeResult!.firstFailed!.reason!)
            else
              const SizedBox.shrink(),
            if (activeResult?.firstFailed?.reason != null) const SizedBox(height: 4) else const SizedBox.shrink(),
            Text(AppLocalizations.of(context)!.eligible_mistake),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _finish,
            child: Text(AppLocalizations.of(context)!.eligible_back),
          )
        ],
        forceActionsBelow: true,
        backgroundColor: Colors.red[50],
      );

  Widget _constructResultBanner() => activeResult!.eligible ? _constructPassBanner() : _constructFailBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.eligibility_questionnaire_title),
        leading: Icon(MdiIcons.clipboardList),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              AppLocalizations.of(context)!.please_answer_eligibility,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: QuestionnaireWidget(
              widget.study!.questionnaire.questions,
              title: widget.study!.title,
              onChange: _invalidateResponse,
              onComplete: _evaluateResponse,
              shouldContinue: _checkContinuation,
            ),
          ),
          if (activeResult != null) _constructResultBanner(),
        ],
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: activeResult?.eligible ?? false ? _finish : null,
        progress: const OnboardingProgress(stage: 0, progress: 0.5),
      ),
    );
  }
}
