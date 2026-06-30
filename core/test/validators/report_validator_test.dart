import 'package:studyu_core/src/models/data/data_reference.dart';
import 'package:studyu_core/src/models/observations/tasks/questionnaire_task.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/models/report/sections/average_section.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/report_validator.dart';
import 'package:test/test.dart';

void main() {
  test('passes when report_specification is empty', () {
    final s = Study('id', 'user');
    final r = validateReport(s, ValidationLevel.publish);
    expect(r.valid, isTrue);
  });

  test('fails when resultProperty.task references a non-existent observation', () {
    final s = Study('id', 'user');
    final section = AverageSection.withId();
    section.resultProperty = DataReference<num>('missing-obs-id', 'q-id');
    s.reportSpecification.secondary = [section];
    final r = validateReport(s, ValidationLevel.publish);
    expect(r.valid, isFalse);
    expect(r.errors.first.code, 'report.task_reference_missing');
  });

  test('fails when resultProperty.property references a non-existent question', () {
    final obs = QuestionnaireTask.withId();
    obs.questions = StudyUQuestionnaire();
    // no questions added

    final s = Study('id', 'user');
    s.observations = [obs];

    final section = AverageSection.withId();
    section.resultProperty = DataReference<num>(obs.id, 'missing-q-id');
    s.reportSpecification.secondary = [section];

    final r = validateReport(s, ValidationLevel.publish);
    expect(r.valid, isFalse);
    expect(r.errors.first.code, 'report.property_reference_missing');
  });
}
