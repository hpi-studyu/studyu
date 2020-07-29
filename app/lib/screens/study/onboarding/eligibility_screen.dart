import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/models/models.dart';

import '../../../util/localization.dart';
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
  final Study study;

  static MaterialPageRoute<EligibilityResult> routeFor({@required Study study}) => MaterialPageRoute(
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
    Navigator.of(context).pop(activeResult);
  }

  Widget _constructPassBanner() => MaterialBanner(
        leading: Icon(
          MdiIcons.checkboxMarkedCircle,
          color: Colors.green,
          size: 32,
        ),
        content: Text('You are eligible for this study.', style: Theme.of(context).textTheme.subtitle1),
        actions: [
          FlatButton(
            onPressed: _finish,
            child: Text('Continue'),
          )
        ],
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
            Text('You are not eligible for this study.', style: Theme.of(context).textTheme.subtitle1),
            SizedBox(height: 4),
            Text(activeResult.firstFailed.reason),
            SizedBox(height: 4),
            Text('If you made a mistake, you can still change your answers.')
          ],
        ),
        actions: [
          FlatButton(
            onPressed: _finish,
            child: Text('Back to study selection'),
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
        title: Text(widget.study.title),
        leading: Icon(MdiIcons.fromString(widget.study.iconName)),
      ),
      body: Column(
        children: [
          if (activeResult != null) _constructResultBanner(),
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        hideNext: true,
        progress: OnboardingProgress(stage: 0, progress: 0.5),
      ),
    );
  }
}
