import 'package:studyu_core/src/models/observations/tasks/questionnaire_task.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/observations_validator.dart';
import 'package:test/test.dart';

Study _studyWithObs(List<dynamic> observations) {
  final s = Study('id', 'user');
  s.observations = observations.cast();
  return s;
}

QuestionnaireTask _obs(String id) {
  final o = QuestionnaireTask.withId();
  o.id = id;
  return o;
}

void main() {
  test('no observations -> passes', () {
    final r = validateObservations(_studyWithObs([]), ValidationLevel.draft);
    expect(r.valid, isTrue);
  });

  test('two observations with unique IDs -> passes', () {
    final r = validateObservations(
      _studyWithObs([_obs('obs-a'), _obs('obs-b')]),
      ValidationLevel.draft,
    );
    expect(r.valid, isTrue);
  });

  test('two observations with same ID -> observations.duplicate_observation_id',
      () {
    final r = validateObservations(
      _studyWithObs([_obs('dup-id'), _obs('dup-id')]),
      ValidationLevel.draft,
    );
    expect(r.valid, isFalse);
    expect(
        r.errors.any(
            (e) => e.code == 'observations.duplicate_observation_id'),
        isTrue);
  });

  test('three observations: first and third share ID -> one error at index 2',
      () {
    final r = validateObservations(
      _studyWithObs([_obs('id-a'), _obs('id-b'), _obs('id-a')]),
      ValidationLevel.draft,
    );
    expect(r.valid, isFalse);
    expect(r.errors.length, 1);
    expect(r.errors.first.code, 'observations.duplicate_observation_id');
    expect(r.errors.first.path, contains('[2]'));
  });
}
