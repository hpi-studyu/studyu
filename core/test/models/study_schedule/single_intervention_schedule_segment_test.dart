import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  group('SingleInterventionScheduleSegment', () {
    test('getDuration returns correct duration', () {
      final segment = SingleInterventionScheduleSegment('a', 7);
      expect(segment.getDuration([]), 7);
    });

    test('getInterventionOnDay returns correct intervention', () {
      final interventionA = Intervention('a', 'Intervention A');
      final interventionB = Intervention('b', 'Intervention B');
      final interventions = [interventionA, interventionB];
      final segment = SingleInterventionScheduleSegment('a', 7);

      expect(segment.getInterventionOnDay(0, interventions, []), interventionA);
      expect(segment.getInterventionOnDay(6, interventions, []), interventionA);
    });

    test('getInterventionOnDay throws error for invalid day', () {
      final interventionA = Intervention('a', 'Intervention A');
      final interventions = [interventionA];
      final segment = SingleInterventionScheduleSegment('a', 7);

      expect(
        () => segment.getInterventionOnDay(-1, interventions, []),
        throwsArgumentError,
      );
      expect(
        () => segment.getInterventionOnDay(8, interventions, []),
        throwsArgumentError,
      );
    });

    test('serialization works', () {
      final segment = SingleInterventionScheduleSegment('a', 7);
      final json = segment.toJson();
      expect(json['type'], 'singleIntervention');
      expect(json['interventionId'], 'a');
      expect(json['duration'], 7);

      final deserialized = SingleInterventionScheduleSegment.fromJson(json);
      expect(deserialized.interventionId, 'a');
      expect(deserialized.duration, 7);
      expect(deserialized.type, StudyScheduleSegmentType.singleIntervention);
    });
  });
}
