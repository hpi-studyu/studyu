import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/converters/converter_context.dart';
import 'package:studyu_designer_v2/domain/converters/expression_converter.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class QuestionConverter {
  QuestionConverter._();

  static Map<String, dynamic> exportQuestion(
    Question question, {
    required int index,
    required List<Question> allQuestions,
    ExportContext? context,
  }) {
    // Generate schema-local ID for this question
    final schemaId = context?.nextQuestionId(question.id);

    final map = <String, dynamic>{
      if (schemaId != null) 'id': schemaId,
      'type': question.type,
      'prompt': question.prompt,
      if (question.rationale != null) 'rationale': question.rationale,
    };

    if (question is ChoiceQuestion) {
      // Export choices with schema-local IDs
      final choices = question.choices.map((choice) {
        if (context != null) {
          final choiceSchemaId = context.nextChoiceId(choice.id);
          return {'id': choiceSchemaId, 'text': choice.text};
        }
        return choice.text;
      }).toList();

      map['settings'] = {
        'allowMultiple': question.multiple,
        'choices': choices,
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
      final logic = ExpressionConverter.expressionToLogic(
        conditional.condition,
        questions: allQuestions,
        context: context,
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

  static List<Question> importQuestions(
    Map<String, dynamic> form, {
    SchemaIdTranslationMap? idMap,
  }) {
    final questionsJson = form['questions'];
    if (questionsJson is! List) {
      throw const FormatException('Form is missing questions');
    }

    final questions = <Question>[];

    for (final questionMap in questionsJson.cast<Map<String, dynamic>>()) {
      questions.add(importQuestion(questionMap, idMap: idMap));
    }

    return questions;
  }

  static Question importQuestion(
    Map<String, dynamic> data, {
    SchemaIdTranslationMap? idMap,
  }) {
    final type = data['type'] as String?;
    if (type == null || type.isEmpty) {
      throw const FormatException('Question is missing type');
    }

    late final Question question;
    if (type == BooleanQuestion.questionType) {
      question = BooleanQuestion.withId();
    } else if (type == ChoiceQuestion.questionType) {
      question = importChoiceQuestion(data, idMap: idMap);
    } else if (type == AnnotatedScaleQuestion.questionType) {
      question = importAnnotatedScale(data);
    } else if (type == VisualAnalogueQuestion.questionType) {
      question = importVisualAnalogue(data);
    } else if (type == ScaleQuestion.questionType) {
      question = importScaleQuestion(data);
    } else if (type == FreeTextQuestion.questionType) {
      question = importFreeText(data);
    } else if (type == ImageCapturingQuestion.questionType) {
      question = ImageCapturingQuestion.withId();
    } else if (type == AudioRecordingQuestion.questionType) {
      question = importAudioQuestion(data);
    } else if (type == FitbitQuestion.questionType) {
      question = importFitbitQuestion(data);
    } else if (type == PainQuestion.questionType) {
      question = PainQuestion.withId();
    } else {
      throw FormatException('Unsupported question type "$type"');
    }

    question.prompt = data['prompt'] as String?;
    question.rationale = data['rationale'] as String?;

    // Register schema-local ID if present
    if (idMap != null) {
      final schemaId = data['id'] as String?;
      if (schemaId != null) {
        idMap.registerQuestion(schemaId, question.id);
      }
    }

    return question;
  }

  static ChoiceQuestion importChoiceQuestion(
    Map<String, dynamic> data, {
    SchemaIdTranslationMap? idMap,
  }) {
    final question = ChoiceQuestion.withId();
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    question.multiple = settings['allowMultiple'] as bool? ?? false;
    question.choices = (settings['choices'] as List? ?? []).map((entry) {
      Choice choice;
      if (entry is String) {
        choice = Choice.withText(text: entry);
      } else if (entry is Map<String, dynamic>) {
        // V2 format with schema-local IDs
        final schemaId = entry['id'] as String?;
        final text = entry['text'] as String?;

        choice = Choice.withText(text: text ?? '');

        // Register schema-local ID if present
        if (idMap != null && schemaId != null) {
          idMap.registerChoice(schemaId, choice.id);
        }
      } else {
        choice = Choice.withText(text: entry.toString());
      }
      return choice;
    }).toList();
    return question;
  }

  static ScaleQuestion importScaleQuestion(Map<String, dynamic> data) {
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

  static AnnotatedScaleQuestion importAnnotatedScale(
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

  static VisualAnalogueQuestion importVisualAnalogue(
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

  static FreeTextQuestion importFreeText(Map<String, dynamic> data) {
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

  static AudioRecordingQuestion importAudioQuestion(Map<String, dynamic> data) {
    final settings = data['settings'] as Map<String, dynamic>? ?? {};
    return AudioRecordingQuestion.withId(
      (settings['maxRecordingDurationSeconds'] as num?)?.toInt() ?? 60,
    );
  }

  static FitbitQuestion importFitbitQuestion(Map<String, dynamic> data) {
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
}
