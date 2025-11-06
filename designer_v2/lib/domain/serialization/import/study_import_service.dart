import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/serialization/converters/expression_converter.dart';
import 'package:studyu_designer_v2/domain/serialization/utils/export_import_registry.dart';
import 'package:uuid/uuid.dart';

class StudyImportService {
  StudyImportService._();

  static const Uuid _uuid = Uuid();

  static void applyToStudy(Study target, Map<String, dynamic> json) {
    target.title = _asString(json['title']);

    target.description = _asString(json['description'] ?? '');

    target.iconName = _asString(json['icon_name'] ?? target.iconName);

    final contactJson = json['contact'];
    if (contactJson is Map<String, dynamic>) {
      target.contact = Contact.fromJson(contactJson);
    } else if (contactJson is Map) {
      target.contact = Contact.fromJson(Map<String, dynamic>.from(contactJson));
    }

    _importScreening(target, json);

    final questionnaireResult = _importQuestionnaire(
      _requireMap(json, 'questionnaire'),
    );
    target.questionnaire = questionnaireResult.questionnaire;

    target.eligibilityCriteria = _importEligibilityCriteria(
      _requireList(json, 'eligibility_criteria'),
      questionnaireResult.registry,
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

  static void _importScreening(Study target, Map<String, dynamic> json) {
    final screening = _requireMap(json, 'screening');

    target.participation = Participation.fromJson(
      _asString(screening['participation_mode']),
    );

    final resultSharing = screening['result_sharing'] as String?;
    if (resultSharing != null) {
      target.resultSharing = ResultSharing.fromJson(resultSharing);
    }
  }

  static _ImportQuestionnaireResult _importQuestionnaire(
    Map<String, dynamic> json,
  ) {
    final questionnaire = StudyUQuestionnaire();
    final questions = <Question>[];
    final registry = ExportImportRegistry();

    final questionsJson = _requireList(json, 'questions');

    for (final entry in questionsJson) {
      final questionJson = Map<String, dynamic>.from(entry as Map);
      final handle = _asString(questionJson['id']);
      final newQuestionId = _uuid.v4();
      registry.registerQuestionImport(handle, newQuestionId);

      questionJson['id'] = newQuestionId;

      _importQuestionConditional(questionJson, registry);
      _importQuestionChoices(questionJson, registry);
      _fixScaleQuestionInitialValues(questionJson);

      final question = Question.fromJson(questionJson);
      questions.add(question);
    }

    questionnaire.questions = questions;
    return _ImportQuestionnaireResult(
      questionnaire: questionnaire,
      registry: registry,
    );
  }

  static void _importQuestionConditional(
    Map<String, dynamic> questionJson,
    ExportImportRegistry registry,
  ) {
    if (questionJson['conditional'] is Map) {
      final conditionalMap = Map<String, dynamic>.from(
        questionJson['conditional'] as Map,
      );
      if (conditionalMap['condition'] is Map) {
        conditionalMap['condition'] = ExpressionConverter.toIds(
          Map<String, dynamic>.from(conditionalMap['condition'] as Map),
          registry,
        );
        questionJson['conditional'] = conditionalMap;
      }
    }
  }

  static void _importQuestionChoices(
    Map<String, dynamic> questionJson,
    ExportImportRegistry registry,
  ) {
    if (questionJson['choices'] is List) {
      final choicesJson = questionJson['choices'] as List;
      final convertedChoices = <Map<String, dynamic>>[];
      for (final choiceEntry in choicesJson) {
        final choiceJson = Map<String, dynamic>.from(choiceEntry as Map);
        final choiceHandle = _asString(choiceJson['id']);
        final newChoiceId = _uuid.v4();
        registry.registerChoiceImport(choiceHandle, newChoiceId);
        choiceJson['id'] = newChoiceId;
        convertedChoices.add(choiceJson);
      }
      questionJson['choices'] = convertedChoices;
    }
  }

  static List<EligibilityCriterion> _importEligibilityCriteria(
    List<dynamic> entries,
    ExportImportRegistry registry,
  ) {
    final criteria = <EligibilityCriterion>[];
    for (final entry in entries) {
      final criterionJson = Map<String, dynamic>.from(entry as Map);
      final conditionJson = _requireMap(criterionJson, 'condition');

      // Validate that the condition is a supported expression type
      final expressionType = conditionJson['type'] as String?;

      if (expressionType == null) {
        throw const FormatException(
          'Eligibility criterion condition missing "type" field',
        );
      }

      final convertedCondition = ExpressionConverter.toIds(
        conditionJson,
        registry,
      );

      final criterion = EligibilityCriterion.withId()
        ..reason = criterionJson['reason'] as String?
        ..condition = Expression.fromJson(convertedCondition);
      criteria.add(criterion);
    }
    return criteria;
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

  static void _fixScaleQuestionInitialValues(
    Map<String, dynamic> questionJson,
  ) {
    final questionType = questionJson['type'] as String?;

    if (questionType == 'scale' ||
        questionType == 'annotatedScale' ||
        questionType == 'visualAnalogue') {
      if (questionJson['initial'] == null) {
        final minimum = questionJson['minimum'];
        if (minimum != null) {
          questionJson['initial'] = minimum;
        }
      }

      if (questionJson['annotations'] == null) {
        questionJson['annotations'] = [];
      }
    }
  }

  static List<dynamic> _convertQuestionHandlesForImport(List<dynamic> entries) {
    final registry = ExportImportRegistry();

    for (final entry in entries) {
      final questionJson = Map<String, dynamic>.from(entry as Map);
      final handle = _asString(questionJson['id']);
      final newQuestionId = _uuid.v4();
      registry.registerQuestionImport(handle, newQuestionId);

      if (questionJson['choices'] is List) {
        final choices = questionJson['choices'] as List;
        for (final choiceEntry in choices) {
          final choiceJson = Map<String, dynamic>.from(choiceEntry as Map);
          final choiceHandle = _asString(choiceJson['id']);
          final newChoiceId = _uuid.v4();
          registry.registerChoiceImport(choiceHandle, newChoiceId);
        }
      }
    }

    final converted = <Map<String, dynamic>>[];
    for (final entry in entries) {
      final questionJson = Map<String, dynamic>.from(entry as Map);
      final handle = _asString(questionJson['id']);
      questionJson['id'] = registry.questionHandleToId[handle] ?? _uuid.v4();

      _importQuestionConditional(questionJson, registry);
      _fixScaleQuestionInitialValues(questionJson);

      if (questionJson['choices'] is List) {
        final choices = questionJson['choices'] as List;
        final convertedChoices = <Map<String, dynamic>>[];
        for (final choiceEntry in choices) {
          final choiceJson = Map<String, dynamic>.from(choiceEntry as Map);
          final choiceHandle = _asString(choiceJson['id']);
          choiceJson['id'] =
              registry.choiceHandleToId[choiceHandle] ?? _uuid.v4();
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

class _ImportQuestionnaireResult {
  _ImportQuestionnaireResult({
    required this.questionnaire,
    required this.registry,
  });

  final StudyUQuestionnaire questionnaire;
  final ExportImportRegistry registry;
}
