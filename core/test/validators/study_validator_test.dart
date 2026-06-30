import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  group('validateStudy', () {
    test('returns valid for a minimal draft study with a title', () {
      final s = Study('id', 'user');
      s.title = 'My Study';
      final r = validateStudy(s, ValidationLevel.draft);
      expect(r.valid, isTrue);
    });

    test('returns invalid for a draft with missing title', () {
      final s = Study('id', 'user');
      final r = validateStudy(s, ValidationLevel.draft);
      expect(r.valid, isFalse);
    });

    test('catches eligibility reference error and study info error together', () {
      final s = Study('id', 'user');
      // no title → study_info error
      final criterion = EligibilityCriterion.withId();
      final expr = ChoiceExpression();
      expr.target = 'ghost-id';
      criterion.condition = expr;
      s.eligibilityCriteria = [criterion];

      final r = validateStudy(s, ValidationLevel.draft);
      expect(r.valid, isFalse);
      expect(r.errors.length, greaterThanOrEqualTo(2));
      expect(r.errors.any((e) => e.code == 'study_info.title_required'), isTrue);
      expect(r.errors.any((e) => e.code == 'eligibility.target_question_missing'), isTrue);
    });
  });
}
