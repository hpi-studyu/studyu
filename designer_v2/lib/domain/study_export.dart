import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_export_context.dart';

/// Handles the export of Study objects to LLM-friendly JSON schemas.
/// 
/// This class contains all the logic for converting StudyU Study objects
/// into simplified JSON representations that can be easily consumed by
/// Large Language Models for study generation and editing.
class StudyExport {
  StudyExport._();

  /// Converts a [Study] object to a simplified JSON schema.
  /// 
  /// Creates a structured JSON representation with natural language references
  /// instead of UUIDs. The schema includes metadata, schedule, screening forms,
  /// observation forms, interventions, and consent information.
  /// 
  /// Returns a Map containing the complete study schema with version information.
  static Map<String, dynamic> toSchema(Study study) {
    final context = StudyExportContext();
    return {
      'version': 1,
      'metadata': _exportMetadata(study),
      'studySchedule': _exportStudySchedule(study.schedule),
      'screening': _exportScreeningForm(study, context),
      'observations': _exportObservationForms(study, context),
      'interventions': _exportInterventions(study),
      'consent': _exportConsent(study),
    };
  }

  /// Exports study metadata including title, description, and contact information.
  static Map<String, dynamic> _exportMetadata(Study study) {
    return {
      'title': study.title,
      'description': study.description,
      'participation': study.participation.name,
      'resultSharing': study.resultSharing.name,
      'icon': study.iconName,
      'contact': {
        'email': study.contact.email,
        'phone': study.contact.phone,
        'website': study.contact.website,
        'institutionalReviewBoard': study.contact.institutionalReviewBoard ?? '',
        'institutionalReviewBoardNumber': study.contact.institutionalReviewBoardNumber ?? '',
        'researchers': study.contact.researchers ?? '',
      },
    };
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

  static List<Map<String, dynamic>> _exportObservationForms(
    Study study,
    StudyExportContext context,
  ) {
    final observations = <Map<String, dynamic>>[];

    for (final observation in study.observations) {
      if (observation is! QuestionnaireTask) continue;
      observations.add(_exportObservationForm(observation, context));
    }

    return observations;
  }

  static Map<String, dynamic> _exportScreeningForm(
    Study study,
    StudyExportContext context,
  ) {
    final questions = <Map<String, dynamic>>[];

    for (var i = 0; i < study.questionnaire.questions.length; i++) {
      final question = study.questionnaire.questions[i];
      final exported = _exportQuestion(question, index: i);
      questions.add(exported);
      context.registerQuestion('screening', question.prompt ?? 'question_\${i + 1}', question);
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
      'title': study.title,
      'description': study.description,
      'questions': questions,
      if (eligibilityRules != null) 'eligibilityRules': eligibilityRules,
    };
  }

  static Map<String, dynamic> _exportObservationForm(
    QuestionnaireTask observation,
    StudyExportContext context,
  ) {
    final formTitle = observation.title ?? 'observation';
    context.formKeyByObservationId[observation.id] = formTitle;

    final questions = <Map<String, dynamic>>[];

    for (var i = 0; i < observation.questions.questions.length; i++) {
      final question = observation.questions.questions[i];
      final exported = _exportQuestion(question, index: i);
      questions.add(exported);
      context.registerQuestion(formTitle, question.prompt ?? 'question_\${i + 1}', question);
    }

    return {
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

    final conditional = question.conditional;
    if (conditional != null) {
      if (conditional.condition.expressions.isNotEmpty) {
        final logic = _expressionToLogic(
          conditional.condition,
          questions: [],
        );
        if (logic != null) {
          map['displayIf'] = logic;
        }
      }
      if (conditional.defaultValue != null) {
        map['defaultValue'] = conditional.defaultValue;
      }
    }

    if (question is BooleanQuestion) {
      // Boolean questions have no additional settings
    } else if (question is ChoiceQuestion) {
      map['choices'] = question.choices.map((choice) => choice.text).toList();
    } else if (question is ScaleQuestion) {
      map['min'] = question.minimum;
      map['max'] = question.maximum;
      map['step'] = question.step;
      map['defaultValue'] = question.initial;
    } else if (question is AnnotatedScaleQuestion) {
      map['min'] = question.minimum;
      map['max'] = question.maximum;
      map['step'] = question.step;
      map['defaultValue'] = question.initial;
      map['annotations'] = question.annotations
          .map((annotation) => {
                'value': annotation.value,
                'label': annotation.annotation,
              })
          .toList();
    } else if (question is VisualAnalogueQuestion) {
      map['min'] = question.minimum;
      map['max'] = question.maximum;
      map['step'] = question.step;
      map['defaultValue'] = question.initial;
    } else if (question is FreeTextQuestion) {
      // Free text questions have no additional settings
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

  static List<Map<String, dynamic>> _exportInterventions(Study study) {
    return study.interventions.map((intervention) {
      final tasks = <Map<String, dynamic>>[];

      for (final task in intervention.tasks) {
        if (task is CheckmarkTask) {
          tasks.add({
            'type': 'checkmark',
            'title': task.title,
            'header': task.header,
            'footer': task.footer,
            'schedule': _exportSchedule(task.schedule),
          });
        }
      }

      return {
        'name': intervention.name,
        'description': intervention.description,
        'icon': intervention.icon,
        'tasks': tasks,
      };
    }).toList();
  }

  static List<Map<String, dynamic>> _exportConsent(Study study) {
    return study.consent.map((item) {
      return {
        'title': item.title,
        'description': item.description,
        'icon': item.iconName,
      };
    }).toList();
  }

  static Map<String, dynamic>? _expressionToLogic(
    Expression expression, {
    required List<Question> questions,
  }) {
    if (expression is CompositeExpression) {
      final convertedExpressions = expression.expressions
          .map((expr) => _expressionToLogic(expr, questions: questions))
          .whereType<Map<String, dynamic>>()
          .toList();

      if (convertedExpressions.isEmpty) return null;

      if (expression.logicType == LogicType.and) {
        return {'all': convertedExpressions};
      } else {
        return {'any': convertedExpressions};
      }
    }

    if (expression is NotExpression) {
      final innerLogic = _expressionToLogic(expression.expression, questions: questions);
      if (innerLogic == null) return null;
      return {'not': innerLogic};
    }

    if (expression is BooleanExpression) {
      final question = questions.cast<Question?>().firstWhere(
        (q) => q?.id == expression.target,
        orElse: () => null,
      );
      if (question?.prompt == null) return null;

      return {
        'question': question!.prompt,
        'operator': 'isTrue',
      };
    }

    if (expression is ChoiceExpression) {
      final question = questions.cast<Question?>().firstWhere(
        (q) => q?.id == expression.target,
        orElse: () => null,
      );
      if (question?.prompt == null || question is! ChoiceQuestion) return null;

      final choiceTexts = expression.choices
          .map((choiceId) {
            final choice = question.choices.cast<Choice?>().firstWhere(
              (c) => c?.id == choiceId,
              orElse: () => null,
            );
            return choice?.text;
          })
          .whereType<String>()
          .toList();

      if (choiceTexts.isEmpty) return null;

      return {
        'question': question.prompt,
        'operator': 'includesAny',
        'value': choiceTexts,
      };
    }

    return null;
  }
}



