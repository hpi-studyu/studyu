import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/util/localization.dart';

import '../../../widgets/bottom_onboarding_navigation.dart';
import '../../../widgets/questionnaire/questionnaire_widget.dart';
import 'onboarding_progress.dart';

class EligibilityResult {
  final bool eligible;
  final QuestionnaireState answers;
  final EligibilityCriterion firstFailed;

  EligibilityResult(this.answers, {this.eligible, this.firstFailed});
}

class EligibilityScreen extends StatefulWidget {
  final ParseStudy study;

  static MaterialPageRoute<EligibilityResult> routeFor({@required ParseStudy study}) => MaterialPageRoute(
      builder: (_) => EligibilityScreen(study: study), settings: RouteSettings(name: '/eligibilityCheck'));

  const EligibilityScreen({@required this.study, Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  EligibilityResult activeResult;

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
    final criteria = widget.study.studyDetails.eligibility;
    final failingResult = criteria?.firstWhere((element) => element.isViolated(qs), orElse: () => null);
    if (failingResult == null) return true;
    setState(() {
      activeResult = EligibilityResult(qs, eligible: false, firstFailed: failingResult);
    });
    return false;
  }

  void _evaluateResponse(QuestionnaireState qs) {
    final criteria = widget.study.studyDetails.eligibility;
    setState(() {
      final conditionResult = criteria?.every((criterion) => criterion.isSatisfied(qs)) ?? true;
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
        content:
            Text(Nof1Localizations.of(context).translate('eligible_yes'), style: Theme.of(context).textTheme.subtitle1),
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
            Text(Nof1Localizations.of(context).translate('eligible_no'), style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 4),
            Text(activeResult.firstFailed.reason),
            SizedBox(height: 4),
            Text(Nof1Localizations.of(context).translate('eligible_mistake')),
          ],
        ),
        actions: [
          FlatButton(
            onPressed: _finish,
            child: Text(Nof1Localizations.of(context).translate('eligible_back')),
          )
        ],
        forceActionsBelow: true,
        backgroundColor: Colors.red[50],
      );

  Widget _constructResultBanner() => activeResult.eligible ? _constructPassBanner() : _constructFailBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('eligibility_questionnaire_title')),
        leading: Icon(MdiIcons.clipboardList),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              Nof1Localizations.of(context).translate('please_answer_eligibility'),
              style: theme.textTheme.subtitle1,
            ),
          ),
          Expanded(
            child: QuestionnaireWidget(
              widget.study.studyDetails.questionnaire.questions,
              title: widget.study.title,
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
        progress: OnboardingProgress(stage: 0, progress: 0.5),
      ),
    );
  }
}
