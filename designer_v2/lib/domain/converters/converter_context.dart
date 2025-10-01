import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

/// Import mode detection for schema format
enum ImportMode {
  /// V1 Designer format or V2 without IDs (prompt-based references)
  promptBased,

  /// V2 LLM format with schema-local IDs
  schemaLocalIds,
}

/// Translation map for schema-local IDs to database UUIDs
class SchemaIdTranslationMap {
  final Map<String, String> questionIds = {}; // q_1 -> UUID
  final Map<String, String> choiceIds = {}; // c1_1 -> UUID
  final Map<String, String> interventionIds = {}; // int_1 -> UUID
  final Map<String, String> observationIds = {}; // obs_1 -> UUID

  void registerQuestion(String schemaId, String uuid) {
    questionIds[schemaId] = uuid;
  }

  void registerChoice(String schemaId, String uuid) {
    choiceIds[schemaId] = uuid;
  }

  void registerIntervention(String schemaId, String uuid) {
    interventionIds[schemaId] = uuid;
  }

  void registerObservation(String schemaId, String uuid) {
    observationIds[schemaId] = uuid;
  }

  String? resolveQuestionId(String schemaId) {
    return questionIds[schemaId];
  }

  String? resolveChoiceId(String schemaId) {
    return choiceIds[schemaId];
  }

  String? resolveInterventionId(String schemaId) {
    return interventionIds[schemaId];
  }

  String? resolveObservationId(String schemaId) {
    return observationIds[schemaId];
  }
}

class ExportContext {
  final Map<String, String> formKeyByObservationId = {};
  final Map<String, Map<String, Question>> questionsByFormKey = {};

  // ID counters for schema-local IDs
  int _questionCounter = 0;
  int _observationCounter = 0;
  int _interventionCounter = 0;
  final Map<int, int> _choiceCounters = {}; // question number -> choice counter

  // Reverse mappings: UUID -> schema-local ID
  final Map<String, String> questionIdToSchemaId = {};
  final Map<String, String> choiceIdToSchemaId = {};
  final Map<String, String> observationIdToSchemaId = {};
  final Map<String, String> interventionIdToSchemaId = {};

  String nextQuestionId(String uuid) {
    _questionCounter++;
    final schemaId = 'q_$_questionCounter';
    questionIdToSchemaId[uuid] = schemaId;
    return schemaId;
  }

  String nextChoiceId(String uuid) {
    final questionNum = _questionCounter;
    _choiceCounters[questionNum] = (_choiceCounters[questionNum] ?? 0) + 1;
    final schemaId = 'c${questionNum}_${_choiceCounters[questionNum]}';
    choiceIdToSchemaId[uuid] = schemaId;
    return schemaId;
  }

  String nextObservationId(String uuid) {
    _observationCounter++;
    final schemaId = 'obs_$_observationCounter';
    observationIdToSchemaId[uuid] = schemaId;
    return schemaId;
  }

  String nextInterventionId(String uuid) {
    _interventionCounter++;
    final schemaId = 'int_$_interventionCounter';
    interventionIdToSchemaId[uuid] = schemaId;
    return schemaId;
  }

  String? getQuestionSchemaId(String uuid) {
    return questionIdToSchemaId[uuid];
  }

  String? getChoiceSchemaId(String uuid) {
    return choiceIdToSchemaId[uuid];
  }

  void registerQuestion(String formKey, String questionKey, Question question) {
    final form = questionsByFormKey.putIfAbsent(formKey, () => {});
    form[questionKey] = question;
  }

  Map<String, String>? exportDataReference(DataReference<num> reference) {
    final formTitle = formKeyByObservationId[reference.task];
    if (formTitle == null) return null;
    final questions = questionsByFormKey[formTitle];
    if (questions == null) return null;
    for (final entry in questions.entries) {
      if (entry.value.id == reference.property) {
        return {'form': formTitle, 'question': entry.key};
      }
    }
    return null;
  }
}

class ImportContext {
  final Map<String, Map<String, Question>> questionsByFormKey = {};
  final Map<String, String> formKeyToObservationId = {};
  final List<Map<String, dynamic>> conditionalData = [];
  Map<String, dynamic>? eligibilityData;

  /// Import mode for this schema
  ImportMode mode = ImportMode.promptBased;

  /// Translation map for schema-local IDs (only used in schemaLocalIds mode)
  final SchemaIdTranslationMap idMap = SchemaIdTranslationMap();

  void registerQuestion(String formKey, String questionKey, Question question) {
    questionsByFormKey.putIfAbsent(formKey, () => {})[questionKey] = question;
  }

  void addConditionalData(String formName, Map<String, dynamic> formData) {
    conditionalData.add({'formName': formName, 'formData': formData});
  }

  void addEligibilityData(Map<String, dynamic> formData) {
    eligibilityData = formData;
  }

  Question? findQuestionByPrompt(String prompt) {
    for (final formQuestions in questionsByFormKey.values) {
      for (final question in formQuestions.values) {
        if (question.prompt == prompt) {
          return question;
        }
      }
    }
    return null;
  }

  /// Find question by schema-local ID (for LLM format)
  Question? findQuestionById(String schemaId) {
    final uuid = idMap.resolveQuestionId(schemaId);
    if (uuid == null) return null;

    for (final formQuestions in questionsByFormKey.values) {
      for (final question in formQuestions.values) {
        if (question.id == uuid) {
          return question;
        }
      }
    }
    return null;
  }

  String? findChoiceId(String questionPrompt, String choiceText) {
    final question = findQuestionByPrompt(questionPrompt);
    if (question is ChoiceQuestion) {
      final choice = question.choices.firstWhereOrNull(
        (c) => c.text == choiceText,
      );
      return choice?.id;
    }
    return null;
  }

  /// Find choice UUID by schema-local ID (for LLM format)
  String? findChoiceIdBySchemaId(String schemaChoiceId) {
    return idMap.resolveChoiceId(schemaChoiceId);
  }

  DataReference<num>? importDataReference(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final formKey = data['form'] as String?;
    final questionKey = data['question'] as String?;
    if (formKey == null || questionKey == null) return null;
    final observationId = formKeyToObservationId[formKey];
    final question = findQuestionByPrompt(questionKey);
    if (observationId == null || question == null) return null;
    return DataReference<num>(observationId, question.id);
  }
}

bool? coerceBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is String) {
    final lower = value.toLowerCase().trim();
    if (lower == 'true') return true;
    if (lower == 'false') return false;
  }
  return null;
}

List<String>? coerceChoiceList(dynamic value) {
  if (value is List) {
    return value.map((element) => element.toString()).toList();
  }
  if (value is String && value.isNotEmpty) {
    return [value];
  }
  return null;
}
