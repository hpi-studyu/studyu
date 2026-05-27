import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/onboarding/onboarding_progress.dart';
import 'package:studyu_app/widgets/bottom_onboarding_navigation.dart';
import 'package:studyu_app/widgets/questionnaire/questionnaire_widget.dart';
import 'package:studyu_core/core.dart';

class EligibilityResult {
  final bool eligible;
  final QuestionnaireState answers;
  final EligibilityCriterion? firstFailed;

  EligibilityResult(this.answers, {required this.eligible, this.firstFailed});
}

class EligibilityScreen extends StatefulWidget {
  final Study? study;

  static MaterialPageRoute<EligibilityResult> routeFor({
    required Study? study,
  }) => MaterialPageRoute(
    builder: (_) => EligibilityScreen(study: study),
    settings: const RouteSettings(name: '/eligibilityCheck'),
  );

  const EligibilityScreen({required this.study, super.key});

  @override
  State<StatefulWidget> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  EligibilityResult? activeResult;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    activeResult = null;
  }

  void _invalidateResponse() {
    setState(() {
      activeResult = null;
    });
  }

  bool _checkContinuation(QuestionnaireState qs) {
    // Invalidate any existing result when checking continuation
    // This ensures the banner disappears when answers change
    if (activeResult != null) {
      setState(() {
        activeResult = null;
      });
    }

    final criteria = widget.study!.eligibilityCriteria;
    final EligibilityCriterion? failingResult = criteria.firstWhereOrNull(
      (element) => element.isViolated(qs),
    );
    if (failingResult == null) return true;
    // freetext quickfix start
    // failingResult = _isFreeTextCriterion(failingResult) ? null : failingResult;
    // freetext quickfix end
    setState(() {
      activeResult = EligibilityResult(
        qs,
        eligible: false,
        firstFailed: failingResult,
      );
    });
    return false;
  }

  void _evaluateResponse(QuestionnaireState? qs) {
    if (qs == null) {
      _invalidateResponse();
      return;
    }
    final criteria = widget.study!.eligibilityCriteria;
    setState(() {
      final isEligible = criteria.every((criterion) {
        // freetext quickfix start
        /*if (_isFreeTextCriterion(criterion)) {
          print('Criterion is free text, automatically satisfying it.');
          return true;
        }*/
        // freetext quickfix end
        return criterion.isSatisfied(qs);
      });
      if (isEligible) {
        activeResult = EligibilityResult(qs, eligible: isEligible);
      } else {
        final firstFailed = criteria.firstWhere(
          (criterion) => criterion.isViolated(qs),
        );
        activeResult = EligibilityResult(
          qs,
          eligible: isEligible,
          firstFailed: firstFailed,
        );
      }
    });
  }

  // todo quickfix until other question types are implemented (see DesignerV2's QuestionFormData)
  // make all free text questions eligible
  // does not work
  /*bool _isFreeTextCriterion(EligibilityCriterion criterion) {
    return widget.study?.questionnaire.questions.any((element) {
          if (criterion.condition.type == ChoiceExpression.expressionType) {
            final ChoiceExpression choiceExpression =
                criterion.condition as ChoiceExpression;
            return element.id == choiceExpression.target!;
          }
          return false;
        }) ??
        false;
  }*/

  void _finish() {
    Navigator.pop(context, activeResult);
  }

  Widget _constructPassBanner() => MaterialBanner(
    key: const ValueKey('eligibility_pass_banner'),
    leading: Icon(MdiIcons.checkboxMarkedCircle, color: Colors.green, size: 32),
    content: Text(
      AppLocalizations.of(context)!.eligible_yes,
      style: Theme.of(context).textTheme.titleMedium,
    ),
    actions: [Container()],
    forceActionsBelow: true,
    backgroundColor: Colors.green[50],
  );

  Widget _constructFailBanner() => MaterialBanner(
    key: const ValueKey('eligibility_fail_banner'),
    leading: Icon(MdiIcons.closeCircle, color: Colors.red, size: 32),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.eligible_no,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        if (activeResult?.firstFailed?.reason != null)
          Text(activeResult!.firstFailed!.reason!)
        else
          const SizedBox.shrink(),
        if (activeResult?.firstFailed?.reason != null)
          const SizedBox(height: 4)
        else
          const SizedBox.shrink(),
        Text(AppLocalizations.of(context)!.eligible_mistake),
      ],
    ),
    actions: [
      TextButton(
        key: const ValueKey('eligibility_back'),
        onPressed: _finish,
        child: Text(AppLocalizations.of(context)!.eligible_back),
      ),
    ],
    forceActionsBelow: true,
    backgroundColor: Colors.red[50],
  );

  Widget _constructResultBanner() =>
      activeResult!.eligible ? _constructPassBanner() : _constructFailBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      key: const ValueKey('eligibility_screen'),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.eligibility_questionnaire_title,
        ),
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
              onComplete: _evaluateResponse,
              shouldContinue: _checkContinuation,
            ),
          ),
          if (activeResult != null) _constructResultBanner(),
        ],
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        nextButtonKey: const ValueKey('eligibility_continue'),
        onNext: activeResult?.eligible ?? false ? _finish : null,
        progress: const OnboardingProgress(stage: 0, progress: 0.5),
      ),
    );
  }
}
