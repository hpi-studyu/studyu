import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';


/// Provides a human-readable translation of the study schedule
extension PhaseSequenceFormatted on PhaseSequence {
  String get string {
    switch (this) {
      case PhaseSequence.alternating:
        return tr.alternating_abab;
      case PhaseSequence.counterBalanced:
        return "Counterbalanced (AB BA)".hardcoded;
      case PhaseSequence.randomized:
        return "Random".hardcoded; // TODO random between both options?
      default:
        return "[Invalid PhaseSequence]";
    }
  }
}
