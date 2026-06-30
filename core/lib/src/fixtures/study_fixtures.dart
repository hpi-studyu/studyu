import 'package:studyu_core/src/models/eligibility/eligibility_criterion.dart';
import 'package:studyu_core/src/models/expressions/types/choice_expression.dart';
import 'package:studyu_core/src/models/interventions/intervention.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/models/tables/study.dart';

class StudyFixtures {
  StudyFixtures._();

  /// A minimal valid draft study.
  static Study minimal() {
    final s = Study('fixture-minimal', 'fixture-user');
    s.title = 'Minimal Study';
    return s;
  }

  /// A fully populated valid study ready to publish.
  static Study fullValid() {
    final s = Study('fixture-full', 'fixture-user');
    s.title = 'Full Valid Study';
    s.description = 'A complete study for testing';
    s.iconName = 'accountHeart';
    s.contact.email = 'test@studyu.health';
    s.contact.organization = 'Test Org';
    s.contact.institutionalReviewBoard = 'Test IRB';
    s.contact.institutionalReviewBoardNumber = 'IRB-001';
    s.contact.researchers = 'Alice, Bob';
    s.contact.phone = '+1234567890';
    s.contact.website = 'https://studyu.health';

    final intervention = Intervention.withId();
    intervention.name = 'Treatment A';
    s.interventions = [intervention];

    s.schedule.phaseDuration = 7;
    s.schedule.numberOfCycles = 2;

    return s;
  }

  /// An invalid study missing title (triggers study_info.title_required).
  static Study invalidMissingTitle() {
    final s = Study('fixture-no-title', 'fixture-user');
    // title intentionally left null
    return s;
  }

  /// An invalid study with a broken eligibility criterion reference.
  static Study invalidBrokenEligibilityRef() {
    final s = Study('fixture-broken-ref', 'fixture-user');
    s.title = 'Broken Ref Study';

    // Screener question
    final q = BooleanQuestion.withId();
    s.questionnaire.questions = [q];

    // Criterion that references a non-existent question id
    final criterion = EligibilityCriterion.withId();
    final expr = ChoiceExpression();
    expr.target = 'non-existent-uuid';
    criterion.condition = expr;
    s.eligibilityCriteria = [criterion];

    return s;
  }
}
