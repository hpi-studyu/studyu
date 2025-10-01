import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/converters/converter_context.dart';
import 'package:studyu_designer_v2/domain/converters/expression_converter.dart';
import 'package:studyu_designer_v2/domain/converters/question_converter.dart';
import 'package:studyu_designer_v2/domain/converters/schedule_converter.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudyImportConverter {
  StudyImportConverter._();

  /// Detects the import mode by checking if schema uses schema-local IDs
  static ImportMode detectImportMode(Map<String, dynamic> schema) {
    // Check version field hint
    final version = schema['version'] as int?;
    if (version == 1) {
      return ImportMode.promptBased;
    }

    // Check source field hint
    final source = schema['source'] as String?;
    if (source == 'llm') {
      return ImportMode.schemaLocalIds;
    }

    // Check if observations have questions with ID fields
    final observations = schema['observations'];
    if (observations is List && observations.isNotEmpty) {
      final firstObs = observations[0];
      if (firstObs is Map<String, dynamic>) {
        final questions = firstObs['questions'];
        if (questions is List && questions.isNotEmpty) {
          final firstQuestion = questions[0];
          if (firstQuestion is Map<String, dynamic>) {
            // If question has 'id' field with pattern q_\d+, it's LLM format
            final questionId = firstQuestion['id'];
            if (questionId is String && questionId.startsWith('q_')) {
              return ImportMode.schemaLocalIds;
            }
          }
        }
      }
    }

    // Check if screening questions have IDs
    final screening = schema['screening'];
    if (screening is Map<String, dynamic>) {
      final questions = screening['questions'];
      if (questions is List && questions.isNotEmpty) {
        final firstQuestion = questions[0];
        if (firstQuestion is Map<String, dynamic>) {
          final questionId = firstQuestion['id'];
          if (questionId is String && questionId.startsWith('q_')) {
            return ImportMode.schemaLocalIds;
          }
        }
      }
    }

    // Default to prompt-based (v1 format or v2 without IDs)
    return ImportMode.promptBased;
  }

  /// Validates platform constraints
  static void validatePlatformConstraints(Map<String, dynamic> schema) {
    // Check max interventions
    final interventions = schema['interventions'];
    if (interventions is List && interventions.length > 2) {
      throw const FormatException(
        'Maximum 2 interventions allowed by platform constraints',
      );
    }

    // Check phase duration
    final schedule = schema['schedule'] ?? schema['studySchedule'];
    if (schedule is Map<String, dynamic>) {
      final phaseDuration = schedule['phaseDuration'] as int?;
      if (phaseDuration != null && phaseDuration < 1) {
        throw const FormatException(
          'Phase duration must be >= 1 day (platform constraint)',
        );
      }
    }
  }

  static void importMetadata(Map<String, dynamic> metadata, Study study) {
    study.title = metadata['title'] as String?;
    study.description = metadata['description'] as String? ?? '';

    final participation = metadata['participation'] as String?;
    if (participation != null) {
      study.participation =
          Participation.values.firstWhereOrNull(
            (value) => value.name == participation,
          ) ??
          study.participation;
    }

    final resultSharing = metadata['resultSharing'] as String?;
    if (resultSharing != null) {
      study.resultSharing =
          ResultSharing.values.firstWhereOrNull(
            (value) => value.name == resultSharing,
          ) ??
          study.resultSharing;
    }

    study.iconName = metadata['icon'] as String? ?? '';

    final contact = metadata['contact'];
    if (contact is Map<String, dynamic>) {
      study.contact = Contact.fromJson(contact);
    }
  }

  static void importStudySchedule(
    Map<String, dynamic>? data,
    StudySchedule schedule,
  ) {
    if (data == null) {
      return;
    }
    schedule.numberOfCycles =
        (data['numberOfCycles'] as num?)?.toInt() ?? schedule.numberOfCycles;
    schedule.phaseDuration =
        (data['phaseDuration'] as num?)?.toInt() ?? schedule.phaseDuration;
    schedule.includeBaseline =
        data['includeBaseline'] as bool? ?? schedule.includeBaseline;
    final sequence = data['sequence'] as String?;
    if (sequence != null) {
      schedule.sequence =
          PhaseSequence.values.firstWhereOrNull(
            (value) => value.name == sequence,
          ) ??
          schedule.sequence;
    }
    schedule.sequenceCustom =
        data['sequenceCustom'] as String? ?? schedule.sequenceCustom;
  }

  static void importScreeningForm(
    dynamic screeningData,
    Study study,
    ImportContext context,
  ) {
    if (screeningData is! Map<String, dynamic>) return;

    final form = screeningData;
    const formName = 'screening';

    // Pass idMap if in schemaLocalIds mode
    final idMap = context.mode == ImportMode.schemaLocalIds
        ? context.idMap
        : null;
    final questionsData = QuestionConverter.importQuestions(form, idMap: idMap);
    study.questionnaire.questions = questionsData;

    for (var i = 0; i < questionsData.length; i++) {
      final question = questionsData[i];
      context.registerQuestion(
        formName,
        question.prompt ?? 'question_${i + 1}',
        question,
      );
    }

    context.addConditionalData(formName, form);
    context.addEligibilityData(form);
  }

  static void importEligibility(
    dynamic eligibilityData,
    Study study,
    ImportContext context,
  ) {
    if (eligibilityData is! Map<String, dynamic>) return;

    // V2 format with screening questions in eligibility section
    if (eligibilityData.containsKey('screeningQuestions')) {
      final screeningForm = {
        'questions': eligibilityData['screeningQuestions'],
      };
      const formName = 'screening';

      final idMap = context.mode == ImportMode.schemaLocalIds
          ? context.idMap
          : null;
      final questionsData = QuestionConverter.importQuestions(
        screeningForm,
        idMap: idMap,
      );
      study.questionnaire.questions = questionsData;

      for (var i = 0; i < questionsData.length; i++) {
        final question = questionsData[i];
        context.registerQuestion(
          formName,
          question.prompt ?? 'question_${i + 1}',
          question,
        );
      }

      context.addConditionalData(formName, screeningForm);
    }

    // Add eligibility rules
    context.addEligibilityData(eligibilityData);
  }

  static void importObservations(
    dynamic observationsData,
    Study study,
    ImportContext context,
  ) {
    if (observationsData is! List) return;

    for (final observationJson
        in observationsData.cast<Map<String, dynamic>>()) {
      importObservationForm(observationJson, study, context);
    }
  }

  static void importObservationForm(
    Map<String, dynamic> form,
    Study study,
    ImportContext context,
  ) {
    final formTitle = form['title'] as String? ?? 'observation';

    // Pass idMap if in schemaLocalIds mode
    final idMap = context.mode == ImportMode.schemaLocalIds
        ? context.idMap
        : null;
    final questionsData = QuestionConverter.importQuestions(form, idMap: idMap);

    final task = QuestionnaireTask.withId()
      ..title = form['title'] as String?
      ..header = form['description'] as String?
      ..questions = StudyUQuestionnaire()
      ..questions.questions = questionsData
      ..schedule = ScheduleConverter.importSchedule(
        form['schedule'] as Map<String, dynamic>?,
      );

    study.observations.add(task);
    context.formKeyToObservationId[formTitle] = task.id;

    // Register observation schema-local ID if present
    if (idMap != null) {
      final obsSchemaId = form['id'] as String?;
      if (obsSchemaId != null) {
        idMap.registerObservation(obsSchemaId, task.id);
      }
    }

    for (var i = 0; i < questionsData.length; i++) {
      final question = questionsData[i];
      context.registerQuestion(
        formTitle,
        question.prompt ?? 'question_${i + 1}',
        question,
      );
    }

    context.addConditionalData(formTitle, form);
  }

  static void importInterventions(dynamic data, Study study) {
    if (data is! List) return;
    study.interventions = data.map((entry) {
      final map = entry as Map<String, dynamic>;
      final intervention = Intervention.withId()
        ..name = map['name'] as String?
        ..description = map['description'] as String?
        ..icon = map['icon'] as String? ?? '';
      final tasks = (map['tasks'] as List? ?? []).cast<Map<String, dynamic>>();
      intervention.tasks = tasks
          .map((taskMap) {
            final type = taskMap['type'] as String?;
            if (type == CheckmarkTask.taskType) {
              return CheckmarkTask.withId()
                ..title = taskMap['title'] as String?
                ..header = taskMap['header'] as String?
                ..footer = taskMap['footer'] as String?
                ..schedule = ScheduleConverter.importSchedule(
                  taskMap['schedule'] as Map<String, dynamic>?,
                );
            }
            return null;
          })
          .whereType<InterventionTask>()
          .toList();
      return intervention;
    }).toList();
  }

  static void importConsent(dynamic data, Study study) {
    if (data is! List) return;
    study.consent = data.map((entry) {
      final map = entry as Map<String, dynamic>;
      return ConsentItem.withId()
        ..title = map['title'] as String?
        ..description = map['description'] as String?
        ..iconName = map['icon'] as String? ?? 'textBoxCheck';
    }).toList();
  }

  static void resolveConditionals(Study study, ImportContext context) {
    for (final data in context.conditionalData) {
      final formName = data['formName'] as String;
      final formData = data['formData'] as Map<String, dynamic>;
      final questionsJson = formData['questions'] as List?;

      if (questionsJson != null) {
        for (var i = 0; i < questionsJson.length; i++) {
          final questionData = questionsJson[i] as Map<String, dynamic>;
          final question = context.questionsByFormKey[formName]?.values
              .toList()[i];

          if (question != null) {
            final displayIf =
                questionData['displayIf'] as Map<String, dynamic>?;
            final defaultAnswer = questionData['defaultAnswer'];

            if (displayIf != null || defaultAnswer != null) {
              final conditional = buildConditionalFromNaturalLanguage(
                question,
                displayIf,
                defaultAnswer,
                context,
              );
              if (conditional != null) {
                question.conditional = conditional;
              }
            }
          }
        }
      }
    }

    if (context.eligibilityData != null) {
      final eligibilityRules =
          context.eligibilityData!['eligibilityRules'] as Map<String, dynamic>?;
      if (eligibilityRules != null) {
        final expressions = ExpressionConverter.extractIndividualExpressions(
          eligibilityRules,
          context,
        );
        study
            .eligibilityCriteria = expressions.whereType<ValueExpression>().map((
          expression,
        ) {
          final criterion = EligibilityCriterion.withId();
          // EligibilityCriterion expects a single Expression (not CompositeExpression)
          // This matches the native UI pattern where each criterion has one simple condition
          criterion.condition = expression;
          return criterion;
        }).toList();
      }
    }
  }

  /// Resolves V2 conditional format with schema-local IDs
  static Expression? resolveConditionalWithIds(
    Map<String, dynamic> displayIf,
    ImportContext context,
  ) {
    // Handle composite conditionals (type: "composite")
    final type = displayIf['type'] as String?;
    if (type == 'composite') {
      // For now, flatten to first condition (same as v1 for compatibility)
      final conditions = displayIf['conditions'] as List?;
      if (conditions != null && conditions.isNotEmpty) {
        return resolveConditionalWithIds(
          conditions[0] as Map<String, dynamic>,
          context,
        );
      }
      return null;
    }

    // Handle v1-style wrapped conditions ({"all": [...]})
    if (displayIf.containsKey('all')) {
      final conditions = displayIf['all'] as List;
      if (conditions.isNotEmpty) {
        return resolveConditionalWithIds(
          conditions[0] as Map<String, dynamic>,
          context,
        );
      }
      return null;
    }

    // Simple conditional with schema-local ID
    final questionId = displayIf['questionId'] as String?;
    final questionPrompt = displayIf['questionPrompt'] as String?;

    // Try ID-based resolution first (v2), fallback to prompt (v1 compatibility)
    Question? targetQuestion;
    if (questionId != null) {
      targetQuestion = context.findQuestionById(questionId);
    } else if (questionPrompt != null) {
      targetQuestion = context.findQuestionByPrompt(questionPrompt);
    }

    if (targetQuestion == null) return null;

    final operator = (displayIf['operator'] as String? ?? 'equals').trim();

    switch (operator) {
      case 'isTrue':
        return BooleanExpression()..target = targetQuestion.id;

      case 'isFalse':
        // Not supported in current expression system
        return null;

      case 'equals':
      case 'includesAny':
        final exp = ChoiceExpression()..target = targetQuestion.id;

        // Try ID-based choice resolution first
        final choiceIds = displayIf['choiceIds'] as List?;
        if (choiceIds != null && targetQuestion is ChoiceQuestion) {
          final resolvedIds = choiceIds
              .cast<String>()
              .map((schemaId) => context.findChoiceIdBySchemaId(schemaId))
              .whereType<String>()
              .toSet();
          exp.choices = resolvedIds;
        } else {
          // Fallback to choice text resolution (v1 compatibility)
          final choiceTexts = displayIf['choiceTexts'] as List?;
          final value = displayIf['value'];
          final textsToResolve = choiceTexts ?? (value is List ? value : null);

          if (textsToResolve != null && targetQuestion is ChoiceQuestion) {
            final prompt = targetQuestion.prompt;
            if (prompt != null) {
              final resolvedIds = textsToResolve
                  .map((text) => context.findChoiceId(prompt, text.toString()))
                  .whereType<String>()
                  .toSet();
              exp.choices = resolvedIds;
            }
          }
        }

        if (exp.choices.isEmpty) return null;
        return exp;

      case 'greaterThan':
      case 'lessThan':
      case 'notEquals':
        // Not commonly used in current system
        return null;

      default:
        return null;
    }
  }

  static QuestionConditional? buildConditionalFromNaturalLanguage(
    Question question,
    Map<String, dynamic>? displayIf,
    dynamic defaultValue,
    ImportContext context,
  ) {
    // If no conditional logic and no default value, return null (no conditional)
    if (displayIf == null && defaultValue == null) {
      return null;
    }

    // If only default value without display logic, create unconditional with default
    if (displayIf == null) {
      if (question is BooleanQuestion) {
        final conditional = QuestionConditional<bool>();
        conditional.defaultValue = coerceBool(defaultValue);
        return conditional;
      }
      if (question is ChoiceQuestion) {
        final conditional = QuestionConditional<List<String>>();
        conditional.defaultValue = coerceChoiceList(defaultValue);
        return conditional;
      }
      if (question is SliderQuestion) {
        final conditional = QuestionConditional<num>();
        conditional.defaultValue = defaultValue is num ? defaultValue : null;
        return conditional;
      }
      if (question is FreeTextQuestion) {
        final conditional = QuestionConditional<String>();
        conditional.defaultValue = defaultValue?.toString();
        return conditional;
      }
      return QuestionConditional();
    }

    // Resolve expression based on import mode
    final Expression? expression;
    if (context.mode == ImportMode.schemaLocalIds) {
      // V2 format with schema-local IDs
      expression = resolveConditionalWithIds(displayIf, context);
    } else {
      // V1 format with prompt-based references
      expression = ExpressionConverter.logicToExpressionWithNaturalLanguage(
        displayIf,
        context,
      );
    }

    // If we couldn't create a valid expression, create conditional with only default value
    if (expression == null || expression is! ValueExpression) {
      if (question is BooleanQuestion) {
        final conditional = QuestionConditional<bool>();
        conditional.defaultValue = coerceBool(defaultValue);
        return conditional;
      }
      if (question is ChoiceQuestion) {
        final conditional = QuestionConditional<List<String>>();
        conditional.defaultValue = coerceChoiceList(defaultValue);
        return conditional;
      }
      if (question is SliderQuestion) {
        final conditional = QuestionConditional<num>();
        conditional.defaultValue = defaultValue is num ? defaultValue : null;
        return conditional;
      }
      if (question is FreeTextQuestion) {
        final conditional = QuestionConditional<String>();
        conditional.defaultValue = defaultValue?.toString();
        return conditional;
      }
      return QuestionConditional();
    }

    // Create CompositeExpression with single ValueExpression (native UI pattern)
    final finalExpression = CompositeExpression(
      logicType: LogicType.and,
      expressions: [expression],
    );

    if (question is BooleanQuestion) {
      final defaultBool = coerceBool(defaultValue);
      return QuestionConditional<bool>.withCondition(
        finalExpression,
        defaultValue: defaultBool,
      );
    }
    if (question is ChoiceQuestion) {
      final defaultChoices = coerceChoiceList(defaultValue);
      return QuestionConditional<List<String>>.withCondition(
        finalExpression,
        defaultValue: defaultChoices,
      );
    }
    if (question is SliderQuestion) {
      final num? defaultNum = defaultValue is num ? defaultValue : null;
      return QuestionConditional<num>.withCondition(
        finalExpression,
        defaultValue: defaultNum,
      );
    }
    if (question is FreeTextQuestion) {
      return QuestionConditional<String>.withCondition(
        finalExpression,
        defaultValue: defaultValue?.toString(),
      );
    }
    if (question is PainQuestion) {
      return QuestionConditional<List<BodyPart>>.withCondition(finalExpression);
    }
    if (question is ImageCapturingQuestion) {
      return QuestionConditional<ImageCapturingQuestion>.withCondition(
        finalExpression,
      );
    }
    if (question is AudioRecordingQuestion) {
      return QuestionConditional<AudioRecordingQuestion>.withCondition(
        finalExpression,
      );
    }
    if (question is FitbitQuestion) {
      return QuestionConditional<FitbitQuestion>.withCondition(finalExpression);
    }

    return QuestionConditional.withCondition(finalExpression);
  }
}
