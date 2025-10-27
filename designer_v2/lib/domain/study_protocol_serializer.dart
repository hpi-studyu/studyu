import 'dart:convert';

import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/utils/json_format.dart';
import 'package:uuid/uuid.dart';

class StudyProtocolSerializer {
  StudyProtocolSerializer._();

  static const String _questionnaireHandle = 'screening';
  static const Uuid _uuid = Uuid();

  static Map<String, dynamic> exportStudy(Study study) {
    final registry = _ExportRegistry();
    final questionnaireJson = _exportScreeningQuestionnaire(
      study,
      registry: registry,
    );
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
        'questionnaire_ref': _questionnaireHandle,
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

  static void applyToStudy(Study target, Map<String, dynamic> json) {
    target.title = _asString(json['title']);
    target.description = _asString(json['description'] ?? '');
    target.iconName = _asString(json['icon_name'] ?? target.iconName);
    target.contact = Contact.fromJson(_requireMap(json, 'contact'));

    final screening = _requireMap(json, 'screening');
    target.participation = Participation.fromJson(
      _asString(screening['participation_mode']),
    );
    final resultSharing = screening['result_sharing'] as String?;
    if (resultSharing != null) {
      target.resultSharing = ResultSharing.fromJson(resultSharing);
    }

    final questionnaireJson = _requireMap(json, 'questionnaire');
    final screeningQuestionnaire = _importQuestionnaire(questionnaireJson);
    target.questionnaire = screeningQuestionnaire.questionnaire;

    target.eligibilityCriteria = _importEligibilityCriteria(
      _requireList(json, 'eligibility_criteria'),
      screeningQuestionnaire.questionHandleToId,
      screeningQuestionnaire.choiceHandleToId,
    );

    target.interventions = _importInterventions(
      _requireList(json, 'interventions'),
    );

    target.observations = _importObservations(
      _requireList(json, 'observations'),
    );

    target.schedule = StudySchedule.fromJson(
      Map<String, dynamic>.from(json['schedule'] as Map),
    );

    target.consent = _importConsent(_requireList(json, 'consent'));
  }

  static String encodePretty(Map<String, dynamic> payload) {
    return prettyJson(payload);
  }

  static Map<String, dynamic> decode(String content) {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Study protocol must be a JSON object');
    }
    return decoded;
  }

  // ---------------------------------------------------------------------------
  // Export helpers
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _exportScreeningQuestionnaire(
    Study study, {
    required _ExportRegistry registry,
  }) {
    final questions = _exportQuestions(
      study.questionnaire.questions,
      baseHandle: '${_questionnaireHandle}_q',
      registry: registry,
    );
    return <String, dynamic>{
      'id': _questionnaireHandle,
      'title': study.title ?? '',
      'questions': questions,
    };
  }

  static List<Map<String, dynamic>> _exportQuestions(
    List<Question> questions, {
    required String baseHandle,
    _ExportRegistry? registry,
  }) {
    final exported = <Map<String, dynamic>>[];
    for (var index = 0; index < questions.length; index++) {
      final question = questions[index];
      final handle = '$baseHandle${index + 1}';
      registry?.registerQuestion(question.id, handle);

      final questionJson = Map<String, dynamic>.from(question.toJson());
      questionJson['id'] = handle;

      // Export conditional if present, converting expression handles
      if (questionJson['conditional'] is Map && registry != null) {
        final conditionalMap = Map<String, dynamic>.from(
          questionJson['conditional'] as Map,
        );
        if (conditionalMap['condition'] is Map) {
          conditionalMap['condition'] = _convertExpressionToHandles(
            Map<String, dynamic>.from(conditionalMap['condition'] as Map),
            registry,
          );
          questionJson['conditional'] = conditionalMap;
        }
      } else if (questionJson['conditional'] is Map && registry == null) {
        // If no registry available (e.g., observation questions),
        // keep conditional but without handle conversion
        // This maintains the conditional for observation questions
      }

      if (question is ChoiceQuestion) {
        final newChoices = <Map<String, dynamic>>[];
        for (
          var choiceIndex = 0;
          choiceIndex < question.choices.length;
          choiceIndex++
        ) {
          final choice = question.choices[choiceIndex];
          final choiceHandle = '${handle}_opt${choiceIndex + 1}';
          registry?.registerChoice(choice.id, choiceHandle);
          final choiceJson = Map<String, dynamic>.from(choice.toJson());
          choiceJson['id'] = choiceHandle;
          newChoices.add(choiceJson);
        }
        questionJson['choices'] = newChoices;
      } else if (questionJson['choices'] is List) {
        final choices = questionJson['choices'] as List;
        final newChoices = <Map<String, dynamic>>[];
        for (var choiceIndex = 0; choiceIndex < choices.length; choiceIndex++) {
          final choiceJson = Map<String, dynamic>.from(
            choices[choiceIndex] as Map,
          );
          final choiceHandle = '${handle}_opt${choiceIndex + 1}';
          registry?.registerChoice(_asString(choiceJson['id']), choiceHandle);
          choiceJson['id'] = choiceHandle;
          newChoices.add(choiceJson);
        }
        questionJson['choices'] = newChoices;
      }

      exported.add(questionJson);
    }
    return exported;
  }

  static List<Map<String, dynamic>> _exportEligibilityCriteria(
    List<EligibilityCriterion> criteria,
    _ExportRegistry registry,
  ) {
    final exported = <Map<String, dynamic>>[];
    for (var index = 0; index < criteria.length; index++) {
      final criterion = criteria[index];
      final conditionJson = criterion.condition.toJson();
      final convertedCondition = _convertExpressionToHandles(
        conditionJson,
        registry,
      );

      final map = <String, dynamic>{
        'id': 'criterion_${index + 1}',
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
    for (
      var interventionIndex = 0;
      interventionIndex < interventions.length;
      interventionIndex++
    ) {
      final intervention = interventions[interventionIndex];
      final handle = 'intervention_${interventionIndex + 1}';
      final interventionJson = Map<String, dynamic>.from(intervention.toJson());
      interventionJson['id'] = handle;

      if (interventionJson['tasks'] is List) {
        final tasksJson = <Map<String, dynamic>>[];
        for (
          var taskIndex = 0;
          taskIndex < intervention.tasks.length;
          taskIndex++
        ) {
          final task = intervention.tasks[taskIndex];
          final taskHandle = '${handle}_task_${taskIndex + 1}';
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
      final handle = 'observation_${index + 1}';
      final observationJson = Map<String, dynamic>.from(observation.toJson());
      observationJson['id'] = handle;

      if (observationJson['schedule'] is Map<String, dynamic>) {
        observationJson['schedule'] = _exportSchedule(
          Map<String, dynamic>.from(observationJson['schedule'] as Map),
          handle,
        );
      }

      if (observation is QuestionnaireTask) {
        // Create a registry for this observation's questions
        // so conditionals can reference questions within the same observation
        final observationRegistry = _ExportRegistry();
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
      map['id'] = 'consent_${index + 1}';
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
        periodJson['id'] = '${baseHandle}_period_${index + 1}';
        exportedPeriods.add(periodJson);
      }
      result['completionPeriods'] = exportedPeriods;
    }
    return result;
  }

  static Map<String, dynamic> _convertExpressionToHandles(
    Map<String, dynamic> expression,
    _ExportRegistry registry,
  ) {
    final result = Map<String, dynamic>.from(expression);
    final type = result['type'] as String?;

    if (result.containsKey('target')) {
      final targetId = _asString(result['target']);
      final handle = registry.questionIdToHandle[targetId];
      if (handle != null) {
        result['target'] = handle;
      }
    }

    if (type == 'choice') {
      final choices = result['choices'];
      if (choices is List) {
        result['choices'] = choices
            .map(
              (choiceId) =>
                  registry.choiceIdToHandle[_asString(choiceId)] ?? choiceId,
            )
            .toList();
      }
    } else if (type == 'composite') {
      final expressions = result['expressions'];
      if (expressions is List) {
        result['expressions'] = expressions
            .map(
              (entry) => _convertExpressionToHandles(
                Map<String, dynamic>.from(entry as Map),
                registry,
              ),
            )
            .toList();
      }
    } else if (type == 'not') {
      final nested = result['expression'];
      if (nested is Map) {
        result['expression'] = _convertExpressionToHandles(
          Map<String, dynamic>.from(nested),
          registry,
        );
      }
    }

    return result;
  }

  // ---------------------------------------------------------------------------
  // Import helpers
  // ---------------------------------------------------------------------------

  static _ImportQuestionnaireResult _importQuestionnaire(
    Map<String, dynamic> json,
  ) {
    final questionnaire = StudyUQuestionnaire();
    final questions = <Question>[];
    final questionHandleToId = <String, String>{};
    final choiceHandleToId = <String, String>{};

    final questionsJson = _requireList(json, 'questions');
    for (final entry in questionsJson) {
      final questionJson = Map<String, dynamic>.from(entry as Map);
      final handle = _asString(questionJson['id']);
      final newQuestionId = _uuid.v4();
      questionHandleToId[handle] = newQuestionId;

      questionJson['id'] = newQuestionId;

      // Import conditional if present, converting handles back to IDs
      // Conditional is optional - skip if not present
      if (questionJson['conditional'] is Map) {
        final conditionalMap = Map<String, dynamic>.from(
          questionJson['conditional'] as Map,
        );
        if (conditionalMap['condition'] is Map) {
          conditionalMap['condition'] = _convertExpressionHandlesToIds(
            Map<String, dynamic>.from(conditionalMap['condition'] as Map),
            questionHandleToId,
            choiceHandleToId,
          );
          questionJson['conditional'] = conditionalMap;
        }
      }

      if (questionJson['choices'] is List) {
        final choicesJson = questionJson['choices'] as List;
        final convertedChoices = <Map<String, dynamic>>[];
        for (final choiceEntry in choicesJson) {
          final choiceJson = Map<String, dynamic>.from(choiceEntry as Map);
          final choiceHandle = _asString(choiceJson['id']);
          final newChoiceId = _uuid.v4();
          choiceHandleToId[choiceHandle] = newChoiceId;
          choiceJson['id'] = newChoiceId;
          convertedChoices.add(choiceJson);
        }
        questionJson['choices'] = convertedChoices;
      }

      final question = Question.fromJson(questionJson);
      questions.add(question);
    }

    questionnaire.questions = questions;
    return _ImportQuestionnaireResult(
      questionnaire: questionnaire,
      questionHandleToId: questionHandleToId,
      choiceHandleToId: choiceHandleToId,
    );
  }

  static List<EligibilityCriterion> _importEligibilityCriteria(
    List<dynamic> entries,
    Map<String, String> questionHandleToId,
    Map<String, String> choiceHandleToId,
  ) {
    final criteria = <EligibilityCriterion>[];
    for (final entry in entries) {
      final criterionJson = Map<String, dynamic>.from(entry as Map);
      final conditionJson = _requireMap(
        criterionJson,
        'condition',
      ); // throws if missing
      final convertedCondition = _convertExpressionHandlesToIds(
        conditionJson,
        questionHandleToId,
        choiceHandleToId,
      );

      final criterion = EligibilityCriterion.withId()
        ..reason = criterionJson['reason'] as String?
        ..condition = Expression.fromJson(convertedCondition);
      criteria.add(criterion);
    }
    return criteria;
  }

  static Map<String, dynamic> _convertExpressionHandlesToIds(
    Map<String, dynamic> expression,
    Map<String, String> questionHandleToId,
    Map<String, String> choiceHandleToId,
  ) {
    final result = Map<String, dynamic>.from(expression);
    final type = result['type'] as String?;

    if (result.containsKey('target')) {
      final handle = _asString(result['target']);
      final mappedId = questionHandleToId[handle];
      if (mappedId == null) {
        throw FormatException('Unknown question handle "$handle"');
      }
      result['target'] = mappedId;
    }

    if (type == 'choice') {
      final choices = result['choices'];
      if (choices is List) {
        result['choices'] = choices.map((choiceHandle) {
          if (choiceHandle is String) {
            final mappedId = choiceHandleToId[choiceHandle];
            if (mappedId == null) {
              throw FormatException('Unknown choice handle "$choiceHandle"');
            }
            return mappedId;
          }
          return choiceHandle;
        }).toList();
      }
    } else if (type == 'composite') {
      final expressions = result['expressions'];
      if (expressions is List) {
        result['expressions'] = expressions
            .map(
              (entry) => _convertExpressionHandlesToIds(
                Map<String, dynamic>.from(entry as Map),
                questionHandleToId,
                choiceHandleToId,
              ),
            )
            .toList();
      }
    } else if (type == 'not') {
      final nested = result['expression'];
      if (nested is Map) {
        result['expression'] = _convertExpressionHandlesToIds(
          Map<String, dynamic>.from(nested),
          questionHandleToId,
          choiceHandleToId,
        );
      }
    }

    return result;
  }

  static List<Intervention> _importInterventions(List<dynamic> entries) {
    final interventions = <Intervention>[];
    for (final entry in entries) {
      final interventionJson = Map<String, dynamic>.from(entry as Map);
      interventionJson['id'] = _uuid.v4();

      if (interventionJson['tasks'] is List) {
        final tasks = interventionJson['tasks'] as List;
        final convertedTasks = <Map<String, dynamic>>[];
        for (final taskEntry in tasks) {
          final taskJson = Map<String, dynamic>.from(taskEntry as Map);
          taskJson['id'] = _uuid.v4();
          if (taskJson['schedule'] is Map<String, dynamic>) {
            taskJson['schedule'] = _importSchedule(
              Map<String, dynamic>.from(taskJson['schedule'] as Map),
            );
          }
          convertedTasks.add(taskJson);
        }
        interventionJson['tasks'] = convertedTasks;
      }

      final intervention = Intervention.fromJson(interventionJson);
      interventions.add(intervention);
    }
    return interventions;
  }

  static List<Observation> _importObservations(List<dynamic> entries) {
    final observations = <Observation>[];
    for (final entry in entries) {
      final observationJson = Map<String, dynamic>.from(entry as Map);
      observationJson['id'] = _uuid.v4();

      if (observationJson['schedule'] is Map<String, dynamic>) {
        observationJson['schedule'] = _importSchedule(
          Map<String, dynamic>.from(observationJson['schedule'] as Map),
        );
      }

      if (observationJson['questions'] is List) {
        observationJson['questions'] = _convertQuestionHandlesForImport(
          List<dynamic>.from(observationJson['questions'] as List),
        );
      }

      final observation = Observation.fromJson(observationJson);
      observations.add(observation);
    }
    return observations;
  }

  static List<dynamic> _convertQuestionHandlesForImport(List<dynamic> entries) {
    // First pass: build handle-to-ID mappings for all questions and choices
    final questionHandleToId = <String, String>{};
    final choiceHandleToId = <String, String>{};
    final tempQuestions = <Map<String, dynamic>>[];

    for (final entry in entries) {
      final questionJson = Map<String, dynamic>.from(entry as Map);
      final handle = _asString(questionJson['id']);
      final newQuestionId = _uuid.v4();
      questionHandleToId[handle] = newQuestionId;
      questionJson['id'] = newQuestionId;

      // Map choice handles if present
      if (questionJson['choices'] is List) {
        final choices = questionJson['choices'] as List;
        for (final choiceEntry in choices) {
          final choiceJson = Map<String, dynamic>.from(choiceEntry as Map);
          final choiceHandle = _asString(choiceJson['id']);
          final newChoiceId = _uuid.v4();
          choiceHandleToId[choiceHandle] = newChoiceId;
        }
      }
      tempQuestions.add(questionJson);
    }

    // Second pass: convert conditionals and choices using the mappings
    final converted = <Map<String, dynamic>>[];
    for (final questionJson in tempQuestions) {
      // Convert conditional if present
      if (questionJson['conditional'] is Map) {
        final conditionalMap = Map<String, dynamic>.from(
          questionJson['conditional'] as Map,
        );
        if (conditionalMap['condition'] is Map) {
          conditionalMap['condition'] = _convertExpressionHandlesToIds(
            Map<String, dynamic>.from(conditionalMap['condition'] as Map),
            questionHandleToId,
            choiceHandleToId,
          );
          questionJson['conditional'] = conditionalMap;
        }
      }

      if (questionJson['choices'] is List) {
        final choices = questionJson['choices'] as List;
        final convertedChoices = <Map<String, dynamic>>[];
        for (final choiceEntry in choices) {
          final choiceJson = Map<String, dynamic>.from(choiceEntry as Map);
          final choiceHandle = _asString(choiceJson['id']);
          // Use the already-mapped ID from first pass
          choiceJson['id'] = choiceHandleToId[choiceHandle] ?? _uuid.v4();
          convertedChoices.add(choiceJson);
        }
        questionJson['choices'] = convertedChoices;
      }

      converted.add(questionJson);
    }
    return converted;
  }

  static List<ConsentItem> _importConsent(List<dynamic> entries) {
    final consentItems = <ConsentItem>[];
    for (final entry in entries) {
      final consentJson = Map<String, dynamic>.from(entry as Map);
      consentJson['id'] = _uuid.v4();
      final consent = ConsentItem.fromJson(consentJson);
      consentItems.add(consent);
    }
    return consentItems;
  }

  static Map<String, dynamic> _importSchedule(Map<String, dynamic> schedule) {
    final result = Map<String, dynamic>.from(schedule);
    final periods = result['completionPeriods'];
    if (periods is List) {
      final convertedPeriods = <Map<String, dynamic>>[];
      for (final entry in periods) {
        final periodJson = Map<String, dynamic>.from(entry as Map);
        periodJson['id'] = _uuid.v4();
        convertedPeriods.add(periodJson);
      }
      result['completionPeriods'] = convertedPeriods;
    }
    return result;
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  static String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  static Map<String, dynamic> _requireMap(
    Map<String, dynamic> source,
    String key,
  ) {
    final value = source[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    throw FormatException('Missing or invalid map for key "$key"');
  }

  static List<dynamic> _requireList(Map<String, dynamic> source, String key) {
    final value = source[key];
    if (value is List) {
      return value;
    }
    throw FormatException('Missing or invalid list for key "$key"');
  }
}

class _ExportRegistry {
  final Map<String, String> questionIdToHandle = {};
  final Map<String, String> choiceIdToHandle = {};

  void registerQuestion(String originalId, String handle) {
    questionIdToHandle[originalId] = handle;
  }

  void registerChoice(String originalId, String handle) {
    choiceIdToHandle[originalId] = handle;
  }
}

class _ImportQuestionnaireResult {
  _ImportQuestionnaireResult({
    required this.questionnaire,
    required this.questionHandleToId,
    required this.choiceHandleToId,
  });

  final StudyUQuestionnaire questionnaire;
  final Map<String, String> questionHandleToId;
  final Map<String, String> choiceHandleToId;
}
