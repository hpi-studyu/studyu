import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

/// Provides a human-readable translation of the study schedule
extension PhaseSequenceFormatted on PhaseSequence {
  String get string {
    switch (this) {
      case PhaseSequence.alternating:
        return "Alternating (AB AB)".hardcoded;
      case PhaseSequence.counterBalanced:
        return "Counterbalanced (AB BA)".hardcoded;
      case PhaseSequence.randomized:
        return "Random".hardcoded; // TODO random between both options?
      default:
        return "[Invalid PhaseSequence]";
    }
  }
}

abstract class IFormDataWithStudySchedule implements IFormData {
  IFormDataWithStudySchedule(this.sequenceType, this.numCycles,
      this.phaseDuration, this.includeBaseline);

  final PhaseSequence sequenceType;
  final int numCycles;
  final int phaseDuration;
  final bool includeBaseline;
}
