import 'package:json_annotation/json_annotation.dart';

import 'slider_question.dart';

part 'annotated_scale_question.g.dart';

@JsonSerializable()
class AnnotatedScaleQuestion extends SliderQuestion {
  static const String questionType = 'annotatedScale';

  List<Annotation> annotations;

  AnnotatedScaleQuestion() : super(questionType);

  factory AnnotatedScaleQuestion.fromJson(Map<String, dynamic> json) => _$AnnotatedScaleQuestionFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AnnotatedScaleQuestionToJson(this);
}

@JsonSerializable()
class Annotation {
  int value;
  String annotation;

  Annotation();

  factory Annotation.fromJson(Map<String, dynamic> json) => _$AnnotationFromJson(json);
  Map<String, dynamic> toJson() => _$AnnotationToJson(this);
}
