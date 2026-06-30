import 'package:studyu_core/src/models/interventions/intervention.dart';
import 'package:studyu_core/src/models/study_schedule/study_schedule.dart';
import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';
import 'package:studyu_core/src/validators/validators/schedule_validator.dart';
import 'package:test/test.dart';

void main() {
  test('fails when phaseDuration is 0', () {
    final s = Study('id', 'user');
    s.schedule.phaseDuration = 0;
    final r = validateSchedule(s, ValidationLevel.publish);
    expect(r.valid, isFalse);
    expect(r.errors.first.code, 'schedule.phase_duration_invalid');
  });

  test('passes with valid schedule and matching intervention count', () {
    final s = Study('id', 'user');
    s.schedule.phaseDuration = 7;
    s.schedule.numberOfCycles = 2;
    s.interventions = [Intervention.withId(), Intervention.withId()];
    final r = validateSchedule(s, ValidationLevel.publish);
    expect(r.valid, isTrue);
  });
}
