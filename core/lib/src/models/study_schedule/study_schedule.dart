import 'package:json_annotation/json_annotation.dart';

part 'study_schedule.g.dart';

@JsonSerializable()
class StudySchedule {
  static const int numberOfPhases = 2;

  int numberOfCycles = 2;
  int phaseDuration = 7;
  bool includeBaseline = true;
  PhaseSequence sequence = PhaseSequence.alternating;

  StudySchedule();

  factory StudySchedule.fromJson(Map<String, dynamic> json) => _$StudyScheduleFromJson(json);
  Map<String, dynamic> toJson() => _$StudyScheduleToJson(this);

  int getNumberOfPhases() => numberOfCycles * numberOfPhases + (includeBaseline ? 1 : 0);

  List<int> generateWith(int firstIntervention) {
    final cycles = Iterable<int>.generate(numberOfCycles);
    final phases = cycles.expand((cycle) => _generateCycle(firstIntervention, cycle)).toList();

    return phases;
  }

  int _nextIntervention(int index) => (index + 1) % numberOfPhases;

  List<int> _generateCycle(int first, int cycle) {
    switch (sequence) {
      case PhaseSequence.alternating:
        return _generateAlternatingCycle(first, cycle);
      case PhaseSequence.counterBalanced:
        return _generateCounterBalancedCycle(first, cycle);
      case PhaseSequence.randomized:
        return _generateRandomizedCycle(first, cycle);
      default:
        throw TypeError();
    }
  }

  List<int> _generateAlternatingCycle(int first, int cycle) => [first, _nextIntervention(first)];

  List<int> _generateCounterBalancedCycle(int first, int cycle) {
    final shift = ((cycle + 1) ~/ 2) % 2;
    final baseSequence = [first, _nextIntervention(first)];

    return shift == 0 ? baseSequence : baseSequence.reversed.toList();
  }

  List<int> _generateRandomizedCycle(int first, int cycle) {
    final phase = [first, _nextIntervention(first)];
    if (cycle > 0) phase.shuffle();
    return phase;
  }
}

enum PhaseSequence { alternating, counterBalanced, randomized }
