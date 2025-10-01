import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/converters/converter_context.dart';
import 'package:studyu_designer_v2/domain/converters/expression_converter.dart';
import 'package:studyu_designer_v2/domain/converters/question_converter.dart';
import 'package:studyu_designer_v2/domain/converters/schedule_converter.dart';

class StudyExportConverter {
  StudyExportConverter._();

  static Map<String, dynamic> exportMetadata(Study study) {
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

  static Map<String, dynamic> exportStudySchedule(StudySchedule schedule) {
    return {
      'numberOfCycles': schedule.numberOfCycles,
      'phaseDuration': schedule.phaseDuration,
      'includeBaseline': schedule.includeBaseline,
      'sequence': schedule.sequence.name,
      'sequenceCustom': schedule.sequenceCustom,
    };
  }

  static Map<String, dynamic> exportScreeningForm(
    Study study,
    ExportContext context,
  ) {
    final allQuestions = study.questionnaire.questions;
    final questions = <Map<String, dynamic>>[];

    for (var i = 0; i < allQuestions.length; i++) {
      final question = allQuestions[i];
      final exported = QuestionConverter.exportQuestion(
        question,
        index: i,
        allQuestions: allQuestions,
        context: context,
      );
      questions.add(exported);
      context.registerQuestion(
        'screening',
        question.prompt ?? 'question_${i + 1}',
        question,
      );
    }

    Map<String, dynamic>? eligibilityRules;
    if (study.eligibilityCriteria.isNotEmpty) {
      final rules = study.eligibilityCriteria
          .map(
            (criterion) => ExpressionConverter.expressionToLogic(
              criterion.condition,
              questions: allQuestions,
              context: context,
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

  static List<Map<String, dynamic>> exportObservations(
    Study study,
    ExportContext context,
  ) {
    final observations = <Map<String, dynamic>>[];

    for (final observation in study.observations) {
      if (observation is! QuestionnaireTask) continue;
      observations.add(exportObservationForm(observation, context));
    }

    return observations;
  }

  static Map<String, dynamic> exportObservationForm(
    QuestionnaireTask observation,
    ExportContext context,
  ) {
    final formTitle = observation.title ?? 'observation';
    context.formKeyByObservationId[observation.id] = formTitle;

    // Generate schema-local ID for observation
    final observationSchemaId = context.nextObservationId(observation.id);

    final allQuestions = observation.questions.questions;
    final questions = <Map<String, dynamic>>[];

    for (var i = 0; i < allQuestions.length; i++) {
      final question = allQuestions[i];
      final exported = QuestionConverter.exportQuestion(
        question,
        index: i,
        allQuestions: allQuestions,
        context: context,
      );
      questions.add(exported);
      context.registerQuestion(
        formTitle,
        question.prompt ?? 'question_${i + 1}',
        question,
      );
    }

    return {
      'id': observationSchemaId,
      'title': observation.title,
      'description': observation.header ?? observation.footer,
      'schedule': ScheduleConverter.exportSchedule(observation.schedule),
      'questions': questions,
    };
  }

  static List<Map<String, dynamic>> exportInterventions(
    Study study,
    ExportContext context,
  ) {
    return [
      for (final intervention in study.interventions)
        {
          'id': context.nextInterventionId(intervention.id),
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
                'schedule': ScheduleConverter.exportSchedule(task.schedule),
              },
          ],
        },
    ];
  }

  static List<Map<String, dynamic>> exportConsent(Study study) {
    return [
      for (final item in study.consent)
        {
          'title': item.title,
          'description': item.description,
          'icon': item.iconName,
        },
    ];
  }
}
