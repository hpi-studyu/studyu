import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:uuid/uuid.dart';

class SimplifiedStudyConverter {
  static const schemaVersion = 1;

  SimplifiedStudyConverter._();

  static Map<String, dynamic> toSchema(Study study) {
    final context = _ExportContext();
    return {
      'version': schemaVersion,
      'metadata': _exportMetadata(study),
      'studySchedule': _exportStudySchedule(study.schedule),
      'forms': _exportForms(study, context),
      'interventions': _exportInterventions(study),
      'consent': _exportConsent(study),
    };
  }

  static Study fromSchema(
    Map<String, dynamic> schema, {
    required String ownerId,
  }) {
    final study = Study.withId(ownerId);
    final context = _ImportContext();

    _importMetadata(schema['metadata'] as Map<String, dynamic>? ?? {}, study);
    _importStudySchedule(
      schema['studySchedule'] as Map<String, dynamic>?,
      study.schedule,
    );

    _importForms(schema['forms'], study, context);
    _importInterventions(schema['interventions'], study);
    _importConsent(schema['consent'], study);

    return study;
  }

  // ---------------------------------------------------------------------------
  // Metadata & schedule
  // ---------------------------------------------------------------------------

  static Map<String, dynamic> _exportMetadata(Study study) {
    return {
      'title': study.title,
      'description': study.description,
      'participation': study.participation.name,
      'resultSharing': study.resultSharing.name,
      'icon': study.iconName,
      'contact': study.contact.toJson(),
      'createdAt': study.createdAt?.toIso8601String(),
    };
  }

  static void _importMetadata(Map<String, dynamic> metadata, Study study) {
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

  static Map<String, dynamic> _exportStudySchedule(StudySchedule schedule) {
    return {
      'numberOfCycles': schedule.numberOfCycles,
      'phaseDuration': schedule.phaseDuration,
      'includeBaseline': schedule.includeBaseline,
      'sequence': schedule.sequence.name,
      'sequenceCustom': schedule.sequenceCustom,
    };
  }

  static void _importStudySchedule(
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

  // ---------------------------------------------------------------------------
  // Forms (questions + eligibility)
  // ---------------------------------------------------------------------------

  static List<Map<String, dynamic>> _exportForms(
    Study study,
    _ExportContext context,
  ) {
    final forms = <Map<String, dynamic>>[];

    if (study.questionnaire.questions.isNotEmpty ||
        study.eligibilityCriteria.isNotEmpty) {
      forms.add(_exportScreeningForm(study, context));
    }

    for (final observation in study.observations) {
      if (observation is! QuestionnaireTask) continue;
      forms.add(_exportObservationForm(observation, context));
    }

    return forms;
  }

  static Map<String, dynamic> _exportScreeningForm(
    Study study,
    _ExportContext context,
  ) {
    final questions = <Map<String, dynamic>>[];

    for (var i = 0; i < study.questionnaire.questions.length; i++) {
      final question = study.questionnaire.questions[i];
      final exported = _exportQuestion(question, index: i);
      questions.add(exported);
      context.registerQuestion('screening', question.prompt ?? 'question_${i + 1}', question);
    }

    Map<String, dynamic>? eligibilityRules;
    if (study.eligibilityCriteria.isNotEmpty) {
      final rules = study.eligibilityCriteria
          .map(
            (criterion) => _expressionToLogic(
              criterion.condition,
              questions: study.questionnaire.questions,
            ),
          )
          .whereType<Map<String, dynamic>>()
          .toList();
      if (rules.isNotEmpty) {
        eligibilityRules = {'all': rules};
      }
    }

    return {
      'purpose': 'screening',
      'title': study.title,
      'description': study.description,
      'questions': questions,
      if (eligibilityRules != null) 'eligibilityRules': eligibilityRules,
    };
  }

  static Map<String, dynamic> _exportObservationForm(
    QuestionnaireTask observation,
    _ExportContext context,
  ) {
    final formTitle = observation.title ?? 'observation';
    context.formKeyByObservationId[observation.id] = formTitle;

    final questions = <Map<String, dynamic>>[];

    for (var i = 0; i < observation.questions.questions.length; i++) {
      final question = observation.questions.questions[i];
      final exported = _exportQuestion(question, index: i);
      questions.add(exported);
      context.registerQuestion(formTitle, question.prompt ?? 'question_${i + 1}', question);
    }

    return {
      'purpose': 'observation',
      'title': observation.title,
      'description': observation.header ?? observation.footer,
      'schedule': _exportSchedule(observation.schedule),
      'questions': questions,
    };
  }

  static Map<String, dynamic> _exportQuestion(
    Question question, {
    required int index,
  }) {
    final map = <String, dynamic>{
      'type': question.type,
      'prompt': question.prompt,
      if (question.rationale != null) 'rationale': question.rationale,
    };

    if (question is ChoiceQuestion) {
      map['settings'] = {
        'allowMultiple': question.multiple,
        'choices': question.choices.map((choice) => choice.text).toList(),
      };
    } else if (question is BooleanQuestion) {
      map['settings'] = const {};
    } else if (question is ScaleQuestion) {
      map['settings'] = {
        'minimum': question.minimum,
        'maximum': question.maximum,
        'step': question.step,
        'initial': question.initial,
        'annotations': [
          for (final annotation in question.annotations)
            {'value': annotation.value, 'label': annotation.annotation},
        ],
        if (question.minColor != null) 'minimumColor': question.minColor,
        if (question.maxColor != null) 'maximumColor': question.maxColor,
      };
    } else if (question is AnnotatedScaleQuestion) {
      map['settings'] = {
        'minimum': question.minimum,
        'maximum': question.maximum,
        'step': question.step,
        'initial': question.initial,
        'annotations': [
          for (final annotation in question.annotations)
            {'value': annotation.value, 'label': annotation.annotation},
        ],
      };
    } else if (question is VisualAnalogueQuestion) {
      map['settings'] = {
        'minimum': question.minimum,
        'maximum': question.maximum,
        'step': question.step,
        'initial': question.initial,
        'minimumColor': question.minimumColor,
        'maximumColor': question.maximumColor,
        'minimumAnnotation': question.minimumAnnotation,
        'maximumAnnotation': question.maximumAnnotation,
      };
    } else if (question is FreeTextQuestion) {
      map['settings'] = {
        'lengthRange': question.lengthRange,
        'textType': question.textType.name,
        if (question.customTypeExpression != null)
          'pattern': question.customTypeExpression,
      };
    } else if (question is ImageCapturingQuestion) {
      map['settings'] = const {};
    } else if (question is AudioRecordingQuestion) {
      map['settings'] = {
        'maxRecordingDurationSeconds': question.maxRecordingDurationSeconds,
      };
    } else if (question is FitbitQuestion) {
      map['settings'] = {
        'types': question.types.map((type) => type.name).toList(),
      };
    } else if (question is PainQuestion) {
      map['settings'] = const {};
    }

    final conditional = question.conditional;
    if (conditional != null) {
      final logic = _expressionToLogic(
        conditional.condition,
        questions: [question],
      );
      if (logic != null) {
        map['displayIf'] = logic;
      }
      if (conditional.defaultValue != null) {
        map['defaultAnswer'] = conditional.defaultValue;
      }
    }

    return map;
  }

  static Map<String, dynamic> _exportSchedule(Schedule schedule) {
    return {
      'completionWindows': [
        for (final period in schedule.completionPeriods)
          {
            'start': period.unlockTime.toString(),
            'end': period.lockTime.toString(),
          },
      ],
      'reminders': [
        for (final reminder in schedule.reminders) reminder.toString(),
      ],
    };
  }

  static void _importForms(
    dynamic formsJson,
    Study study,
    _ImportContext context,
  ) {
    if (formsJson is! List) return;

    for (final formJson in formsJson.cast<Map<String, dynamic>>()) {
      final purpose = formJson['purpose'] as String? ?? 'custom';
      if (purpose == 'screening') {
        _importScreeningForm(formJson, study, context);
      } else {
        _importObservationForm(formJson, study, context);
      }
    }
    
    _resolveConditionals(study, context);
  }

  static void _importScreeningForm(
    Map<String, dynamic> form,
    Study study,
    _ImportContext context,
  ) {
    final formName = 'screening';
    final questionsData = _importQuestions(form);
    study.questionnaire.questions = questionsData;

    for (var i = 0; i < questionsData.length; i++) {
      final question = questionsData[i];
      context.registerQuestion(formName, question.prompt ?? 'question_${i + 1}', question);
    }

    context.addConditionalData(formName, form);
    context.addEligibilityData(form);
  }

  static void _importObservationForm(
    Map<String, dynamic> form,
    Study study,
    _ImportContext context,
  ) {
    final formTitle = form['title'] as String? ?? 'observation';
    final questionsData = _importQuestions(form);

    final task = QuestionnaireTask.withId()
      ..title = form['title'] as String?
      ..header = form['description'] as String?
      ..questions = StudyUQuestionnaire()
      ..questions.questions = questionsData
      ..schedule = _importSchedule(form['schedule'] as Map<String, dynamic>?);

    study.observations.add(task);
    context.formKeyToObservationId[formTitle] = task.id;

    for (var i = 0; i < questionsData.length; i++) {
      final question = questionsData[i];
      context.registerQuestion(formTitle, question.prompt ?? 'question_${i + 1}', question);
    }

    context.addConditionalData(formTitle, form);
  }

  static List<Question> _importQuestions(Map<String, dynamic> form) {
    final questionsJson = form['questions'];
    if (questionsJson is! List) {
      throw const FormatException('Form is missing questions');
    }

    final questions = <Question>[];

    for (final questionMap in questionsJson.cast<Map<String, dynamic>>()) {
      questions.add(_importQuestion(questionMap));
    }

    return questions;
  }

  static Question _importQuestion(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    if (type == null || type.isEmpty) {
      throw const FormatException('Question is missing type');
    }

    late final Question question;
    if (type == BooleanQuestion.questionType) {
      question = BooleanQuestion.withId();
    } else if (type == ChoiceQuestion.questionType) {
      question = _importChoiceQuestion(data);
    } else if (type == AnnotatedScaleQuestion.questionType) {
      question = _importAnnotatedScale(data);
    } else if (type == VisualAnalogueQuestion.questionType) {
      question = _importVisualAnalogue(data);
    } else if (type == ScaleQuestion.questionType) {
      question = _importScaleQuestion(data);
    } else if (type == FreeTextQuestion.questionType) {
      question = _importFreeText(data);
    } else if (type == ImageCapturingQuestion.questionType) {
      question = ImageCapturingQuestion.withId();
    } else if (type == AudioRecordingQuestion.questionType) {
      question = _importAudioQuestion(data);
    } else if (type == FitbitQuestion.questionType) {
      question = _importFitbitQuestion(data);
    } else if (type == PainQuestion.questionType) {
      question = PainQuestion.withId();
    } else {
      throw FormatException('Unsupported question type "$type"');
    }

    question.prompt = data['prompt'] as String?;
    question.rationale = data['rationale'] as String?;

    return question;
  }

  static ChoiceQuestion _importChoiceQuestion(Map<String, dynamic> data) {
    final question = ChoiceQuestion.withId();
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    question.multiple = settings['allowMultiple'] as bool? ?? false;
    question.choices = (settings['choices'] as List? ?? []).map((entry) {
      if (entry is String) {
        return Choice.withText(text: entry);
      } else if (entry is Map<String, dynamic>) {
        return Choice(entry['value'] as String? ?? const Uuid().v4())
          ..text = entry['label'] as String? ?? '';
      }
      return Choice.withText(text: entry.toString());
    }).toList();
    return question;
  }

  static ScaleQuestion _importScaleQuestion(Map<String, dynamic> data) {
    final question = ScaleQuestion.withId();
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    question.minimum = (settings['minimum'] as num?)?.toDouble() ?? 0;
    question.maximum = (settings['maximum'] as num?)?.toDouble() ?? 10;
    question.step = (settings['step'] as num?)?.toDouble() ?? 1;
    question.initial = (settings['initial'] as num?)?.toDouble() ?? 0;
    question.annotations = (settings['annotations'] as List? ?? [])
        .map(
          (entry) => Annotation()
            ..value =
                ((entry as Map<String, dynamic>)['value'] as num?)?.toInt() ?? 0
            ..annotation = entry['label'] as String? ?? '',
        )
        .toList();
    question.minColor = settings['minimumColor'] as int?;
    question.maxColor = settings['maximumColor'] as int?;
    return question;
  }

  static AnnotatedScaleQuestion _importAnnotatedScale(
    Map<String, dynamic> data,
  ) {
    final question = AnnotatedScaleQuestion.withId();
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    question.minimum = (settings['minimum'] as num?)?.toDouble() ?? 0;
    question.maximum = (settings['maximum'] as num?)?.toDouble() ?? 10;
    question.step = (settings['step'] as num?)?.toDouble() ?? 1;
    question.initial = (settings['initial'] as num?)?.toDouble() ?? 0;
    question.annotations = (settings['annotations'] as List? ?? [])
        .map(
          (entry) => Annotation()
            ..value =
                ((entry as Map<String, dynamic>)['value'] as num?)?.toInt() ?? 0
            ..annotation = entry['label'] as String? ?? '',
        )
        .toList();
    return question;
  }

  static VisualAnalogueQuestion _importVisualAnalogue(
    Map<String, dynamic> data,
  ) {
    final question = VisualAnalogueQuestion.withId();
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    question.minimum = (settings['minimum'] as num?)?.toDouble() ?? 0;
    question.maximum = (settings['maximum'] as num?)?.toDouble() ?? 10;
    question.step = (settings['step'] as num?)?.toDouble() ?? 1;
    question.initial = (settings['initial'] as num?)?.toDouble() ?? 0;
    question.minimumColor = settings['minimumColor'] as int? ?? 0xFF0000FF;
    question.maximumColor = settings['maximumColor'] as int? ?? 0xFFFF0000;
    question.minimumAnnotation = settings['minimumAnnotation'] as String? ?? '';
    question.maximumAnnotation = settings['maximumAnnotation'] as String? ?? '';
    return question;
  }

  static FreeTextQuestion _importFreeText(Map<String, dynamic> data) {
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    final textType = settings['textType'] as String? ?? 'any';
    final lengthRange = (settings['lengthRange'] as List? ?? [0, 255])
        .map((value) => (value as num).toInt())
        .toList();
    return FreeTextQuestion.withId(
      textType:
          FreeTextQuestionType.values.firstWhereOrNull(
            (value) => value.name == textType,
          ) ??
          FreeTextQuestionType.any,
      lengthRange: lengthRange.length == 2 ? lengthRange : [0, 255],
      customTypeExpression: settings['pattern'] as String?,
    );
  }

  static AudioRecordingQuestion _importAudioQuestion(
    Map<String, dynamic> data,
  ) {
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    return AudioRecordingQuestion.withId(
      (settings['maxRecordingDurationSeconds'] as num?)?.toInt() ?? 60,
    );
  }

  static FitbitQuestion _importFitbitQuestion(Map<String, dynamic> data) {
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    final types = (settings['types'] as List? ?? [])
        .map(
          (type) => FitbitQuestionType.values.firstWhereOrNull(
            (value) => value.name == type,
          ),
        )
        .whereType<FitbitQuestionType>()
        .toList();
    return FitbitQuestion.withId(
      questionType: FitbitQuestion.questionType,
      types: types,
    );
  }

  static Schedule _importSchedule(Map<String, dynamic>? data) {
    final schedule = Schedule();
    if (data == null) return schedule;
    final completionWindows = (data['completionWindows'] as List? ?? [])
        .cast<Map<String, dynamic>>();
    if (completionWindows.isNotEmpty) {
      schedule.completionPeriods = completionWindows
          .map(
            (window) => CompletionPeriod.noId(
              unlockTime: StudyUTimeOfDay.fromJson(window['start'] as String),
              lockTime: StudyUTimeOfDay.fromJson(window['end'] as String),
            ),
          )
          .toList();
    }
    schedule.reminders = (data['reminders'] as List? ?? [])
        .map((value) => StudyUTimeOfDay.fromJson(value as String))
        .toList();
    return schedule;
  }


  static bool? _coerceBool(dynamic value) {
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

  static List<String>? _coerceChoiceList(dynamic value) {
    if (value is List) {
      return value.map((element) => element.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      return [value];
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Expressions
  // ---------------------------------------------------------------------------

  static Map<String, dynamic>? _expressionToLogic(
    Expression? expression, {
    required List<Question> questions,
  }) {
    if (expression == null) return null;

    if (expression is CompositeExpression) {
      final children = expression.expressions
          .map(
            (child) => _expressionToLogic(
              child,
              questions: questions,
            ),
          )
          .whereType<Map<String, dynamic>>()
          .toList();
      if (children.isEmpty) return null;
      return {expression.logicType == LogicType.and ? 'all' : 'any': children};
    }

    if (expression is NotExpression) {
      final child = _expressionToLogic(
        expression.expression,
        questions: questions,
      );
      if (child == null) return null;
      return {'not': child};
    }

    if (expression is ValueExpression) {
      return _valueExpressionToRule(
        expression,
        questions: questions,
      );
    }

    return null;
  }

  static Map<String, dynamic>? _valueExpressionToRule(
    ValueExpression expression, {
    required List<Question> questions,
  }) {
    final targetId = expression.target;
    if (targetId == null) return null;
    
    final question = questions.firstWhereOrNull((q) => q.id == targetId);
    if (question?.prompt == null) return null;

    if (expression is BooleanExpression) {
      return {'question': question!.prompt, 'operator': 'isTrue'};
    }

    if (expression is ChoiceExpression) {
      if (question is BooleanQuestion) {
        if (expression.choices.contains(true) &&
            expression.choices.contains(false)) {
          return {'question': question.prompt, 'operator': 'exists'};
        }
        if (expression.choices.contains(true)) {
          return {'question': question.prompt, 'operator': 'isTrue'};
        }
        if (expression.choices.contains(false)) {
          return {'question': question.prompt, 'operator': 'isFalse'};
        }
      }
      
      if (question is ChoiceQuestion) {
        final choiceTexts = expression.choices
            .map((choiceId) => question.choices
                .firstWhereOrNull((c) => c.id == choiceId)?.text)
            .whereType<String>()
            .toList();
        return {
          'question': question.prompt,
          'operator': 'includesAny',
          'value': choiceTexts,
        };
      }
      
      return {
        'question': question!.prompt,
        'operator': 'includesAny',
        'value': expression.choices.toList(),
      };
    }

    if (expression is NumericExpression) {
      return {
        'question': question!.prompt,
        'operator': _numericComparatorToOperator(expression.comparator),
        'value': expression.value,
      };
    }

    if (expression is TextExpression) {
      return {
        'question': question!.prompt,
        'operator': _textComparatorToOperator(expression.comparator),
        'value': expression.value,
      };
    }

    return {'question': question!.prompt, 'operator': 'exists'};
  }

  static String _numericComparatorToOperator(NumericComparator comparator) {
    return switch (comparator) {
      NumericComparator.equal => 'eq',
      NumericComparator.notEqual => 'neq',
      NumericComparator.greaterThan => 'gt',
      NumericComparator.lessThan => 'lt',
      NumericComparator.greaterThanOrEqual => 'gte',
      NumericComparator.lessThanOrEqual => 'lte',
    };
  }

  static String _textComparatorToOperator(TextComparator comparator) {
    return switch (comparator) {
      TextComparator.equal => 'eq',
      TextComparator.notEqual => 'neq',
      TextComparator.contains => 'contains',
      TextComparator.doesNotContain => 'notContains',
    };
  }

  static Expression? _logicToExpressionWithNaturalLanguage(
    Map<String, dynamic> logic,
    _ImportContext context,
  ) {
    // For backward compatibility, flatten complex logic to simple ValueExpression
    // This ensures compatibility with original dev branch
    if (logic.containsKey('all')) {
      final conditions = logic['all'] as List;
      if (conditions.isNotEmpty) {
        // Use only the first condition to maintain compatibility
        return _logicToExpressionWithNaturalLanguage(
          conditions[0] as Map<String, dynamic>,
          context,
        );
      }
      return null;
    }

    if (logic.containsKey('any')) {
      final conditions = logic['any'] as List;
      if (conditions.isNotEmpty) {
        // Use only the first condition to maintain compatibility
        return _logicToExpressionWithNaturalLanguage(
          conditions[0] as Map<String, dynamic>,
          context,
        );
      }
      return null;
    }

    if (logic.containsKey('not')) {
      // For 'not' conditions, we need to flip the operator to maintain compatibility
      final innerLogic = logic['not'] as Map<String, dynamic>;
      final flippedLogic = Map<String, dynamic>.from(innerLogic);
      
      // Flip common operators to avoid NotExpression
      if (flippedLogic.containsKey('operator')) {
        final operator = flippedLogic['operator'] as String;
        switch (operator) {
          case 'eq':
            flippedLogic['operator'] = 'neq';
            break;
          case 'neq':
            flippedLogic['operator'] = 'eq';
            break;
          case 'isTrue':
            flippedLogic['operator'] = 'isFalse';
            break;
          case 'isFalse':
            flippedLogic['operator'] = 'isTrue';
            break;
          default:
            // For operators we can't flip, return null to avoid NotExpression
            return null;
        }
      }
      
      return _logicToExpressionWithNaturalLanguage(flippedLogic, context);
    }

    final questionPrompt = logic['question'] as String?;
    if (questionPrompt == null) return null;

    final question = context.findQuestionByPrompt(questionPrompt);
    if (question == null) return null;

    final operator = (logic['operator'] as String? ?? 'eq').trim();
    final value = logic['value'];

    switch (operator) {
      case 'isTrue':
        final expression = BooleanExpression()..target = question.id;
        return expression;
      case 'isFalse':
        // For backward compatibility, represent 'isFalse' as 'isTrue' with inverted logic
        // Since we can't use NotExpression, return null to skip this condition
        return null;
      case 'includesAny':
        final exp = ChoiceExpression()..target = question.id;
        if (value is List && question is ChoiceQuestion) {
          final choiceIds = value
              .map((choiceText) => context.findChoiceId(questionPrompt, choiceText.toString()))
              .whereType<String>()
              .toSet();
          exp.choices = choiceIds;
        } else if (value is Iterable) {
          exp.choices = value.toSet();
        } else if (value != null) {
          exp.choices = {value};
        }
        if (exp.choices.isEmpty) {
          return null;
        }
        return exp;
      case 'eq':
        final exp = ChoiceExpression()..target = question.id;
        if (value is List && question is ChoiceQuestion) {
          final choiceIds = value
              .map((choiceText) => context.findChoiceId(questionPrompt, choiceText.toString()))
              .whereType<String>()
              .toSet();
          exp.choices = choiceIds;
        } else if (value is Iterable) {
          exp.choices = value.toSet();
        } else if (value != null) {
          exp.choices = {value};
        }
        if (exp.choices.isEmpty) {
          return null;
        }
        return exp;
      case 'neq':
        final exp = ChoiceExpression()..target = question.id;
        if (value is List && question is ChoiceQuestion) {
          final choiceIds = value
              .map((choiceText) => context.findChoiceId(questionPrompt, choiceText.toString()))
              .whereType<String>()
              .toSet();
          exp.choices = choiceIds;
        } else if (value is Iterable) {
          exp.choices = value.toSet();
        } else if (value != null) {
          exp.choices = {value};
        }
        if (exp.choices.isEmpty) {
          return null;
        }
        final notExpression = NotExpression();
        notExpression.expression = exp;
        return notExpression;
      case 'gt':
        return NumericExpression(
          comparator: NumericComparator.greaterThan,
          value: (value as num?) ?? 0,
        )..target = question.id;
      case 'gte':
        return NumericExpression(
          comparator: NumericComparator.greaterThanOrEqual,
          value: (value as num?) ?? 0,
        )..target = question.id;
      case 'lt':
        return NumericExpression(
          comparator: NumericComparator.lessThan,
          value: (value as num?) ?? 0,
        )..target = question.id;
      case 'lte':
        return NumericExpression(
          comparator: NumericComparator.lessThanOrEqual,
          value: (value as num?) ?? 0,
        )..target = question.id;
      case 'contains':
        return TextExpression(
          comparator: TextComparator.contains,
          value: value?.toString() ?? '',
        )..target = question.id;
      case 'notContains':
        return TextExpression(
          comparator: TextComparator.doesNotContain,
          value: value?.toString() ?? '',
        )..target = question.id;
      default:
        final exp = ChoiceExpression()..target = question.id;
        if (value is List && question is ChoiceQuestion) {
          final choiceIds = value
              .map((choiceText) => context.findChoiceId(questionPrompt, choiceText.toString()))
              .whereType<String>()
              .toSet();
          exp.choices = choiceIds;
        } else if (value is Iterable) {
          exp.choices = value.toSet();
        } else if (value != null) {
          exp.choices = {value};
        }
        if (exp.choices.isEmpty) {
          return null;
        }
        return exp;
    }
  }

  // ---------------------------------------------------------------------------
  // Interventions & consent
  // ---------------------------------------------------------------------------

  static List<Map<String, dynamic>> _exportInterventions(Study study) {
    return [
      for (final intervention in study.interventions)
        {
          'name': intervention.name,
          'description': intervention.description,
          'icon': intervention.icon,
          'tasks': [
            for (final task in intervention.tasks)
              {
                'type': task.type,
                'title': task.title,
                'header': task.header,
                'footer': task.footer,
                'schedule': _exportSchedule(task.schedule),
              },
          ],
        },
    ];
  }

  static void _importInterventions(dynamic data, Study study) {
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
                ..schedule = _importSchedule(
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

  static List<Map<String, dynamic>> _exportConsent(Study study) {
    return [
      for (final item in study.consent)
        {
          'title': item.title,
          'description': item.description,
          'icon': item.iconName,
        },
    ];
  }

  static void _importConsent(dynamic data, Study study) {
    if (data is! List) return;
    study.consent = data.map((entry) {
      final map = entry as Map<String, dynamic>;
      return ConsentItem.withId()
        ..title = map['title'] as String?
        ..description = map['description'] as String?
        ..iconName = map['icon'] as String? ?? 'textBoxCheck';
    }).toList();
  }

  static void _resolveConditionals(Study study, _ImportContext context) {
    for (final data in context.conditionalData) {
      final formName = data['formName'] as String;
      final formData = data['formData'] as Map<String, dynamic>;
      final questionsJson = formData['questions'] as List?;
      
      if (questionsJson != null) {
        for (var i = 0; i < questionsJson.length; i++) {
          final questionData = questionsJson[i] as Map<String, dynamic>;
          final question = context.questionsByFormKey[formName]?.values.toList()[i];
          
          if (question != null) {
            final displayIf = questionData['displayIf'] as Map<String, dynamic>?;
            final defaultAnswer = questionData['defaultAnswer'];
            
            if (displayIf != null || defaultAnswer != null) {
              final conditional = _buildConditionalFromNaturalLanguage(
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
      final eligibilityRules = context.eligibilityData!['eligibilityRules'] as Map<String, dynamic>?;
      if (eligibilityRules != null) {
        final expressions = _extractIndividualExpressions(eligibilityRules, context);
        study.eligibilityCriteria = expressions.whereType<ValueExpression>().map((expression) {
          final criterion = EligibilityCriterion.withId();
          // EligibilityCriterion expects a single Expression (not CompositeExpression)
          // This matches the native UI pattern where each criterion has one simple condition
          criterion.condition = expression;
          return criterion;
        }).toList();
      }
    }
  }

  static QuestionConditional? _buildConditionalFromNaturalLanguage(
    Question question,
    Map<String, dynamic>? displayIf,
    dynamic defaultValue,
    _ImportContext context,
  ) {
    // If no conditional logic and no default value, return null (no conditional)
    if (displayIf == null && defaultValue == null) {
      return null;
    }

    // If only default value without display logic, create unconditional with default
    if (displayIf == null) {
      if (question is BooleanQuestion) {
        final conditional = QuestionConditional<bool>();
        conditional.defaultValue = _coerceBool(defaultValue);
        return conditional;
      }
      if (question is ChoiceQuestion) {
        final conditional = QuestionConditional<List<String>>();
        conditional.defaultValue = _coerceChoiceList(defaultValue);
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

    final expression = _logicToExpressionWithNaturalLanguage(displayIf, context);

    // If we couldn't create a valid expression, create conditional with only default value
    if (expression == null || expression is! ValueExpression) {
      if (question is BooleanQuestion) {
        final conditional = QuestionConditional<bool>();
        conditional.defaultValue = _coerceBool(defaultValue);
        return conditional;
      }
      if (question is ChoiceQuestion) {
        final conditional = QuestionConditional<List<String>>();
        conditional.defaultValue = _coerceChoiceList(defaultValue);
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
      final defaultBool = _coerceBool(defaultValue);
      return QuestionConditional<bool>.withCondition(
        finalExpression,
        defaultValue: defaultBool,
      );
    }
    if (question is ChoiceQuestion) {
      final defaultChoices = _coerceChoiceList(defaultValue);
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

  static List<Expression> _extractIndividualExpressions(
    Map<String, dynamic> logic,
    _ImportContext context,
  ) {
    final expression = _logicToExpressionWithNaturalLanguage(logic, context);
    if (expression == null) return [];

    if (expression is CompositeExpression && expression.logicType == LogicType.and) {
      return expression.expressions.expand((expr) => 
        expr is CompositeExpression && expr.logicType == LogicType.and 
          ? expr.expressions 
          : [expr]
      ).toList();
    }

    return [expression];
  }
}

class _ExportContext {
  final Map<String, String> formKeyByObservationId = {};
  final Map<String, Map<String, Question>> questionsByFormKey = {};

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

class _ImportContext {
  final Map<String, Map<String, Question>> questionsByFormKey = {};
  final Map<String, String> formKeyToObservationId = {};
  final List<Map<String, dynamic>> conditionalData = [];
  Map<String, dynamic>? eligibilityData;

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

  String? findChoiceId(String questionPrompt, String choiceText) {
    final question = findQuestionByPrompt(questionPrompt);
    if (question is ChoiceQuestion) {
      final choice = question.choices.firstWhereOrNull((c) => c.text == choiceText);
      return choice?.id;
    }
    return null;
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
