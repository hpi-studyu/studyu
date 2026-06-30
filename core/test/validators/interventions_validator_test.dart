import 'package:studyu_core/src/models/interventions/intervention.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/interventions_validator.dart';
import 'package:test/test.dart';

Study _studyWith(List<Intervention> interventions) {
  final s = Study('id', 'user');
  s.interventions = interventions;
  return s;
}

Intervention _namedIntervention(String name) {
  final i = Intervention.withId();
  i.name = name;
  return i;
}

void main() {
  group('validateInterventions - draft', () {
    test('passes with zero interventions', () {
      final r = validateInterventions(_studyWith([]), ValidationLevel.draft);
      expect(r.valid, isTrue);
    });
  });

  group('validateInterventions - publish', () {
    test('fails with zero interventions', () {
      final r = validateInterventions(_studyWith([]), ValidationLevel.publish);
      expect(r.valid, isFalse);
      expect(r.errors.first.code, 'interventions.at_least_one_required');
    });

    test('fails when intervention has no name', () {
      final i = Intervention.withId(); // name is null
      final r = validateInterventions(_studyWith([i]), ValidationLevel.publish);
      expect(r.valid, isFalse);
      expect(r.errors.any((e) => e.code == 'interventions.name_required'), isTrue);
    });

    test('passes with one named intervention', () {
      final r = validateInterventions(
        _studyWith([_namedIntervention('Treatment A')]),
        ValidationLevel.publish,
      );
      expect(r.valid, isTrue);
    });
  });
}
