import 'package:studyu_core/core.dart';
import 'package:test/test.dart';

void main() {
  group('generateWith()', () {
    StudySchedule schedule = StudySchedule();
    setUp(() => schedule = StudySchedule());

    void includeCommonRequirements() {
      test('creates a complete schedule', () {
        schedule
          ..numberOfCycles = 2
          ..phaseDuration = 7
          ..includeBaseline = false;

        final result = schedule.generateWith(0);

        expect(
          result.sublist(0).take(2).toSet().length,
          2,
          reason: 'A cycle was not complete',
        );
        expect(
          result.sublist(2).take(2).toSet().length,
          2,
          reason: 'A cycle was not complete',
        );
      });

      test('respects the first intervention', () {
        schedule
          ..numberOfCycles = 2
          ..phaseDuration = 7
          ..includeBaseline = false;

        expect(
          schedule.generateWith(0).first,
          0,
          reason: 'Did not respect first intervention',
        );
        expect(
          schedule.generateWith(1).first,
          1,
          reason: 'Did not respect first intervention',
        );
      });
    }

    group('Alternating Phase Sequence', () {
      setUp(() => schedule.sequence = PhaseSequence.alternating);
      includeCommonRequirements();

      test('creates an alternating schedule', () {
        schedule
          ..numberOfCycles = 3
          ..phaseDuration = 7
          ..includeBaseline = false;

        void checkAlternating(int first) {
          final result = schedule.generateWith(first);
          for (var i = 0; i < result.length - 1; i++) {
            expect(
              result[i],
              isNot(equals(result[i + 1])),
              reason: 'Phase $i and ${i + 1} have the same intervention',
            );
          }
        }

        checkAlternating(0);
        checkAlternating(1);
      });
    });

    group('Counterbalanced Phase Sequence', () {
      setUp(() => schedule.sequence = PhaseSequence.counterBalanced);
      includeCommonRequirements();

      test('creates a counterbalanced schedule', () {
        schedule
          ..numberOfCycles = 8
          ..phaseDuration = 7
          ..includeBaseline = false;

        void checkCounterBalance(int first) {
          final result = schedule.generateWith(first);

          for (var i = 0; i < 8; i += 2) {
            expect(
              result.sublist(i * 2).take(2),
              result.sublist(i * 2 + 2).take(2).toList().reversed,
              reason: 'Cycles $i and ${i + 1} are not mirrored',
            );
          }
          for (var i = 0; i < 6; i += 2) {
            expect(
              result.sublist(i * 2).take(2),
              isNot(equals(result.sublist(i * 2 + 4).take(2))),
              reason: 'Cycles $i and ${i + 2} were repeated',
            );
          }
        }

        checkCounterBalance(0);
        checkCounterBalance(1);
      });
    });

    group('Randomized Phase Sequence', () {
      setUp(() => schedule.sequence = PhaseSequence.randomized);
      includeCommonRequirements();
    });
  });
}
