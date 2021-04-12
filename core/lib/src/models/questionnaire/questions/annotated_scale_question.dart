import 'package:json_annotation/json_annotation.dart';

import '../question_conditional.dart';
import 'slider_question.dart';

part 'annotated_scale_question.g.dart';

@JsonSerializable()
class AnnotatedScaleQuestion extends SliderQuestion {
  static const String questionType = 'annotatedScale';

  List<Annotation> annotations;

  AnnotatedScaleQuestion() : super(questionType);

  AnnotatedScaleQuestion.designerDefault()
      : annotations = [],
        super.designer(questionType);

  factory AnnotatedScaleQuestion.fromJson(Map<String, dynamic> json) => _$AnnotatedScaleQuestionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AnnotatedScaleQuestionToJson(this);
}

@JsonSerializable()
class Annotation {
  int/*!*/ value;
  String/*!*/ annotation;

  Annotation();

  Annotation.designerDefault()
      : value = 0,
        annotation = '';

  factory Annotation.fromJson(Map<String, dynamic> json) => _$AnnotationFromJson(json);

  Map<String, dynamic> toJson() => _$AnnotationToJson(this);
}
