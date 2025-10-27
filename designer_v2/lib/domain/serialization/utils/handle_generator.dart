import 'package:studyu_designer_v2/domain/serialization/utils/handle_prefixes.dart';

class HandleGenerator {
  HandleGenerator._();

  static String forQuestion(String baseHandle, int index) {
    return '$baseHandle${index + 1}';
  }

  static String forChoice(String questionHandle, int choiceIndex) {
    return '$questionHandle${HandlePrefixes.choice}${choiceIndex + 1}';
  }

  static String forIntervention(int index) {
    return '${HandlePrefixes.intervention}${index + 1}';
  }

  static String forTask(String interventionHandle, int taskIndex) {
    return '${interventionHandle}_${HandlePrefixes.task}${taskIndex + 1}';
  }

  static String forObservation(int index) {
    return '${HandlePrefixes.observation}${index + 1}';
  }

  static String forCriterion(int index) {
    return '${HandlePrefixes.criterion}${index + 1}';
  }

  static String forConsent(int index) {
    return '${HandlePrefixes.consent}${index + 1}';
  }

  static String forPeriod(String baseHandle, int index) {
    return '${baseHandle}_${HandlePrefixes.period}${index + 1}';
  }
}
