import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

import '../question_conditional.dart';

part 'scale_question.g.dart';

@JsonSerializable()
class ScaleQuestion extends SliderQuestion
    implements AnnotatedScaleQuestion, VisualAnalogueQuestion {
  static const String questionType = 'scale';

  @override
  List<Annotation> annotations = [];

  @JsonKey(name: 'min_color')
  int? minColor;

  @JsonKey(name: 'max_color')
  int? maxColor;

  ScaleQuestion() : super(questionType);

  ScaleQuestion.withId() : super.withId(questionType);

  factory ScaleQuestion.fromJson(Map<String, dynamic> json) =>
      _$ScaleQuestionFromJson(json);

  factory ScaleQuestion.fromAnnotatedScaleQuestion(
      AnnotatedScaleQuestion question,) {
    final result = ScaleQuestion()
      ..id = question.id
      ..prompt = question.prompt
      ..rationale = question.rationale
      ..conditional = question.conditional
      ..minimum = question.minimum
      ..maximum = question.maximum
      ..step = question.step
      ..initial = question.initial
      ..annotations = question.annotations;
    return result;
  }

  factory ScaleQuestion.fromVisualAnalogueQuestion(
      VisualAnalogueQuestion question,) {
    final result = ScaleQuestion()
      ..id = question.id
      ..prompt = question.prompt
      ..rationale = question.rationale
      ..conditional = question.conditional
      ..minimum = question.minimum
      ..maximum = question.maximum
      ..step = question.step
      ..initial = question.initial
      ..minimumColor = question.minimumColor
      ..maximumColor = question.maximumColor
      ..minimumAnnotation = question.minimumAnnotation
      ..maximumAnnotation = question.maximumAnnotation;
    return result;
  }

  @override
  Map<String, dynamic> toJson() => _$ScaleQuestionToJson(this);

  @JsonKey(ignore: true)
  List<Annotation> get annotationsSorted =>
      annotations.sorted((a, b) => a.value.compareTo(b.value));

  @JsonKey(ignore: true)
  Annotation? get minAnnotation {
    final firstOrNull = annotationsSorted.firstOrNull;
    if (firstOrNull?.value == minimum) {
      return firstOrNull;
    }
    return null;
  }

  @JsonKey(ignore: true)
  Annotation? get maxAnnotation {
    final lastOrNull = annotationsSorted.lastOrNull;
    if (lastOrNull?.value == maximum) {
      return lastOrNull;
    }
    return null;
  }

  @JsonKey(ignore: true)
  String? get minLabel => minAnnotation?.annotation;

  @JsonKey(ignore: true)
  String? get maxLabel => maxAnnotation?.annotation;

  set minLabel(String? newLabel) {
    if (newLabel != null) {
      minimumAnnotation = newLabel; // _setAnnotationLabel
    } else {
      if (minAnnotation != null) {
        annotations.remove(minAnnotation);
      }
    }
  }

  set maxLabel(String? newLabel) {
    if (newLabel != null) {
      maximumAnnotation = newLabel; // _setAnnotationLabel
    } else {
      if (maxAnnotation != null) {
        annotations.remove(maxAnnotation);
      }
    }
  }

  @JsonKey(ignore: true)
  List<Annotation> get midAnnotations => annotationsSorted
      .where((a) => a.value != minimum && a.value != maximum)
      .toList();

  set midAnnotations(List<Annotation> annotations) {
    final prevMinAnnotation = minAnnotation;
    final prevMaxAnnotation = maxAnnotation;

    final List<Annotation> newAnnotations = [];
    if (prevMinAnnotation != null) {
      newAnnotations.add(prevMinAnnotation);
    }
    newAnnotations.addAll(annotations);
    if (prevMaxAnnotation != null) {
      newAnnotations.add(prevMaxAnnotation);
    }

    this.annotations = newAnnotations;
  }

  @JsonKey(ignore: true)
  List<String> get midLabels =>
      midAnnotations.map((a) => a.annotation).toList();

  @JsonKey(ignore: true)
  List<double> get midValues =>
      midAnnotations.map((a) => a.value.toDouble()).toList();

  Annotation addAnnotation({required int value, required String label}) {
    final annotation = Annotation()
      ..value = value
      ..annotation = label;
    annotations.add(annotation);
    return annotation;
  }

  void _setAnnotationLabel({
    required String newLabel,
    required int atSortedIndex,
    required double atValue,
  }) {
    if (annotations.isNotEmpty && atSortedIndex < annotations.length) {
      final existing = annotationsSorted[atSortedIndex];
      // update label for existing annotation
      if (existing.value == atValue) {
        existing.annotation = newLabel;
        return;
      } // else: fall-through & insert new annotation
    }
    addAnnotation(value: atValue.toInt(), label: newLabel);
  }

  // - VisualAnalogueQuestion

  @override
  @JsonKey(ignore: true)
  String get minimumAnnotation => minAnnotation?.annotation ?? minimum.toString();

  @override
  @JsonKey(ignore: true)
  String get maximumAnnotation => maxAnnotation?.annotation ?? maximum.toString();

  @override
  @JsonKey(ignore: true)
  int get maximumColor => maxColor ?? 0xFFFFFFFF;

  @override
  set maximumColor(int value) => maxColor = value;

  @override
  @JsonKey(ignore: true)
  int get minimumColor => minColor ?? 0xFFFFFFFF;

  @override
  set minimumColor(int value) => minColor = value;

  // - AnnotatedScaleQuestion

  @override
  set maximumAnnotation(String newLabel) {
    _setAnnotationLabel(
      newLabel: newLabel,
      atSortedIndex: annotations.length - 1,
      atValue: maximum,
    );
  }

  @override
  set minimumAnnotation(String newLabel) {
    _setAnnotationLabel(
      newLabel: newLabel,
      atSortedIndex: 0,
      atValue: minimum,
    );
  }
}
