import 'package:studyu_core/src/models/questionnaire/questionnaire.dart';
import 'package:studyu_core/src/models/questionnaire/question.dart';
import 'package:studyu_core/src/models/questionnaire/questions/boolean_question.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/questionnaire_validator.dart';
import 'package:test/test.dart';

StudyUQuestionnaire _questionnaire(List<Question> questions) {
  final q = StudyUQuestionnaire();
  q.questions = questions;
  return q;
}

BooleanQuestion _boolQ(String id, {String? prompt}) {
  final q = BooleanQuestion.withId();
  q.id = id;
  q.prompt = prompt ?? 'Question $id';
  return q;
}

void main() {
  group('validateQuestionnaire', () {
    test('passes for empty questionnaire', () {
      final r = validateQuestionnaire(
        _questionnaire([]),
        r'$.questionnaire',
        ValidationLevel.draft,
      );
      expect(r.valid, isTrue);
    });

    test('fails when two questions share the same id', () {
      final q1 = _boolQ('dup-id');
      final q2 = _boolQ('dup-id');
      final r = validateQuestionnaire(
        _questionnaire([q1, q2]),
        r'$.questionnaire',
        ValidationLevel.draft,
      );
      expect(r.valid, isFalse);
      expect(r.errors.first.code, 'questionnaire.duplicate_question_id');
    });

    test('passes when all question ids are unique', () {
      final r = validateQuestionnaire(
        _questionnaire([_boolQ('a'), _boolQ('b')]),
        r'$.questionnaire',
        ValidationLevel.draft,
      );
      expect(r.valid, isTrue);
    });
  });
}
