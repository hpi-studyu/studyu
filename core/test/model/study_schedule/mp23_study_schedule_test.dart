// Test serializes and deserializes a StudySchedule object

import 'package:studyu_core/src/models/interventions/intervention.dart';
import 'package:studyu_core/src/models/study_schedule/mp23_study_schedule.dart';
import 'package:test/test.dart';

void main() {
  group('StudySchedule', () {
    final Intervention intervention = Intervention("test", "Test");
    final schedule = MP23StudySchedule([intervention]);
    final BaselineScheduleSegment baseline = BaselineScheduleSegment(7);
    schedule.segments = [baseline];

    test('can be serialized and deserialized', () {
      final json = schedule.toJson();
      print(json);

      final newSchedule = MP23StudySchedule.fromJson(json);

      expect(newSchedule, equals(schedule));
      expect(false, true);
    });
  });
}
