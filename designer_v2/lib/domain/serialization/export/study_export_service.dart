import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/serialization/converters/expression_converter.dart';
import 'package:studyu_designer_v2/domain/serialization/utils/export_import_registry.dart';
import 'package:studyu_designer_v2/domain/serialization/utils/handle_generator.dart';
import 'package:studyu_designer_v2/domain/serialization/utils/handle_prefixes.dart';

class StudyExportService {
  StudyExportService._();

  static Map<String, dynamic> exportStudy(Study study) {
    final registry = ExportImportRegistry();
    final questionnaireJson = _exportScreeningQuestionnaire(study, registry);
    final eligibilityJson = _exportEligibilityCriteria(
      study.eligibilityCriteria,
      registry,
    );
    final interventionsJson = _exportInterventions(study.interventions);
    final observationsJson = _exportObservations(study.observations);
    final consentJson = _exportConsent(study.consent);

    return <String, dynamic>{
      '\$schema': 'https://json-schema.org/draft/2020-12/schema',
      '\$id': 'https://studyu.app/schemas/study.json',
      'title': study.title ?? '',
      'description': study.description ?? '',
      'icon_name': study.iconName,
      'contact': study.contact.toJson(),
      'screening': {
        'participation_mode': study.participation.toJson(),
        'questionnaire_ref': HandlePrefixes.questionnaire,
        'result_sharing': study.resultSharing.toJson(),
      },
      'questionnaire': questionnaireJson,
      'eligibility_criteria': eligibilityJson,
      'interventions': interventionsJson,
      'observations': observationsJson,
      'schedule': study.schedule.toJson(),
      'consent': consentJson,
    };
  }

  static Map<String, dynamic> _exportScreeningQuestionnaire(
    Study study,
    ExportImportRegistry registry,
  ) {
    final questions = _exportQuestions(
      study.questionnaire.questions,
      baseHandle: HandlePrefixes.question,
      registry: registry,
    );
    return <String, dynamic>{
      'id': HandlePrefixes.questionnaire,
      'title': study.title ?? '',
      'questions': questions,
    };
  }

  static List<Map<String, dynamic>> _exportQuestions(
    List<Question> questions, {
    required String baseHandle,
    ExportImportRegistry? registry,
  }) {
    final exported = <Map<String, dynamic>>[];
    for (var index = 0; index < questions.length; index++) {
      final question = questions[index];
      final handle = HandleGenerator.forQuestion(baseHandle, index);
      registry?.registerQuestionExport(question.id, handle);

      final questionJson = Map<String, dynamic>.from(question.toJson());
      questionJson['id'] = handle;

      _exportQuestionConditional(questionJson, registry);
      _exportQuestionChoices(question, questionJson, handle, registry);

      exported.add(questionJson);
    }
    return exported;
  }

  static void _exportQuestionConditional(
    Map<String, dynamic> questionJson,
    ExportImportRegistry? registry,
  ) {
    if (questionJson['conditional'] is Map && registry != null) {
      final conditionalMap =
          Map<String, dynamic>.from(questionJson['conditional'] as Map);
      if (conditionalMap['condition'] is Map) {
        conditionalMap['condition'] = ExpressionConverter.toHandles(
          Map<String, dynamic>.from(conditionalMap['condition'] as Map),
          registry,
        );
        questionJson['conditional'] = conditionalMap;
      }
    }
  }

  static void _exportQuestionChoices(
    Question question,
    Map<String, dynamic> questionJson,
    String handle,
    ExportImportRegistry? registry,
  ) {
    if (question is ChoiceQuestion) {
      final newChoices = <Map<String, dynamic>>[];
      for (var i = 0; i < question.choices.length; i++) {
        final choice = question.choices[i];
        final choiceHandle = HandleGenerator.forChoice(handle, i);
        registry?.registerChoiceExport(choice.id, choiceHandle);
        final choiceJson = Map<String, dynamic>.from(choice.toJson());
        choiceJson['id'] = choiceHandle;
        newChoices.add(choiceJson);
      }
      questionJson['choices'] = newChoices;
    } else if (questionJson['choices'] is List) {
      final choices = questionJson['choices'] as List;
      final newChoices = <Map<String, dynamic>>[];
      for (var i = 0; i < choices.length; i++) {
        final choiceJson = Map<String, dynamic>.from(choices[i] as Map);
        final choiceHandle = HandleGenerator.forChoice(handle, i);
        registry?.registerChoiceExport(_asString(choiceJson['id']), choiceHandle);
        choiceJson['id'] = choiceHandle;
        newChoices.add(choiceJson);
      }
      questionJson['choices'] = newChoices;
    }
  }

  static List<Map<String, dynamic>> _exportEligibilityCriteria(
    List<EligibilityCriterion> criteria,
    ExportImportRegistry registry,
  ) {
    final exported = <Map<String, dynamic>>[];
    for (var index = 0; index < criteria.length; index++) {
      final criterion = criteria[index];
      final conditionJson = criterion.condition.toJson();
      final convertedCondition = ExpressionConverter.toHandles(
        conditionJson,
        registry,
      );

      final map = <String, dynamic>{
        'id': HandleGenerator.forCriterion(index),
        'condition': convertedCondition,
      };
      if (criterion.reason != null) {
        map['reason'] = criterion.reason;
      }
      exported.add(map);
    }
    return exported;
  }

  static List<Map<String, dynamic>> _exportInterventions(
    List<Intervention> interventions,
  ) {
    final exported = <Map<String, dynamic>>[];
    for (var i = 0; i < interventions.length; i++) {
      final intervention = interventions[i];
      final handle = HandleGenerator.forIntervention(i);
      final interventionJson = Map<String, dynamic>.from(intervention.toJson());
      interventionJson['id'] = handle;

      if (interventionJson['tasks'] is List) {
        final tasksJson = <Map<String, dynamic>>[];
        for (var j = 0; j < intervention.tasks.length; j++) {
          final task = intervention.tasks[j];
          final taskHandle = HandleGenerator.forTask(handle, j);
          final taskJson = Map<String, dynamic>.from(task.toJson());
          taskJson['id'] = taskHandle;
          if (taskJson['schedule'] is Map<String, dynamic>) {
            taskJson['schedule'] = _exportSchedule(
              Map<String, dynamic>.from(taskJson['schedule'] as Map),
              taskHandle,
            );
          }
          tasksJson.add(taskJson);
        }
        interventionJson['tasks'] = tasksJson;
      }

      exported.add(interventionJson);
    }
    return exported;
  }

  static List<Map<String, dynamic>> _exportObservations(
    List<Observation> observations,
  ) {
    final exported = <Map<String, dynamic>>[];
    for (var index = 0; index < observations.length; index++) {
      final observation = observations[index];
      final handle = HandleGenerator.forObservation(index);
      final observationJson = Map<String, dynamic>.from(observation.toJson());
      observationJson['id'] = handle;

      if (observationJson['schedule'] is Map<String, dynamic>) {
        observationJson['schedule'] = _exportSchedule(
          Map<String, dynamic>.from(observationJson['schedule'] as Map),
          handle,
        );
      }

      if (observation is QuestionnaireTask) {
        final observationRegistry = ExportImportRegistry();
        observationJson['questions'] = _exportQuestions(
          observation.questions.questions,
          baseHandle: '${handle}_q',
          registry: observationRegistry,
        );
      }

      exported.add(observationJson);
    }
    return exported;
  }

  static List<Map<String, dynamic>> _exportConsent(
    List<ConsentItem> consentItems,
  ) {
    final exported = <Map<String, dynamic>>[];
    for (var index = 0; index < consentItems.length; index++) {
      final consent = consentItems[index];
      final map = Map<String, dynamic>.from(consent.toJson());
      map['id'] = HandleGenerator.forConsent(index);
      exported.add(map);
    }
    return exported;
  }

  static Map<String, dynamic> _exportSchedule(
    Map<String, dynamic> scheduleJson,
    String baseHandle,
  ) {
    final result = Map<String, dynamic>.from(scheduleJson);
    final periods = result['completionPeriods'];
    if (periods is List) {
      final exportedPeriods = <Map<String, dynamic>>[];
      for (var index = 0; index < periods.length; index++) {
        final periodJson = Map<String, dynamic>.from(periods[index] as Map);
        periodJson['id'] = HandleGenerator.forPeriod(baseHandle, index);
        exportedPeriods.add(periodJson);
      }
      result['completionPeriods'] = exportedPeriods;
    }
    return result;
  }

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}
