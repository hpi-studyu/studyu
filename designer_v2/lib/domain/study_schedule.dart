import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

/// Provides a human-readable translation of the study schedule
extension PhaseSequenceFormatted on PhaseSequence {
  String get string {
    switch (this) {
      case PhaseSequence.alternating:
        return tr.phase_sequence_alternating;
      case PhaseSequence.counterBalanced:
        return tr.phase_sequence_counterbalanced;
      case PhaseSequence.randomized:
        return tr.phase_sequence_random; // TODO random between both options?
      case PhaseSequence.customized:
        return tr.phase_sequence_custom;
      default:
        return "[Invalid PhaseSequence]";
    }
  }
}
