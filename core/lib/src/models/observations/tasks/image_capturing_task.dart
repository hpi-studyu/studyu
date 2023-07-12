import 'package:collection/collection.dart' show IterableExtension;
import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/models.dart';

part 'image_capturing_task.g.dart';

@JsonSerializable()
class ImageCapturingTask extends Observation {
  static const String taskType = 'image_capturing';

  /*StudyUQuestionnaire questions = StudyUQuestionnaire();*/

  ImageCapturingTask() : super(taskType);

  ImageCapturingTask.withId() : super.withId(taskType);

  factory ImageCapturingTask.fromJson(Map<String, dynamic> json) => _$ImageCapturingTaskFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ImageCapturingTaskToJson(this);

  @override
  Map<DateTime, T> extractPropertyResults<T>(String property, List<SubjectProgress> sourceResults) {
    //TODO: from old questionaire
    final Question? targetQuestion = questions.questions.firstWhereOrNull((q) => q.id == property);
    if (targetQuestion == null) {
      throw ArgumentError("Questionnaire '$id' does not have a question with '$property'.");
    }
    return Map.fromEntries(
      sourceResults
          .map((e) => MapEntry(e.completedAt!, (e.result as Result<QuestionnaireState>).result.getAnswer<T>(property))),
    );
  }

  @override
  Map<String, Type> getAvailableProperties() => {for (var q in questions.questions) q.id: q.getAnswerType()};

  @override
  String? getHumanReadablePropertyName(String property) =>
      //TODO: from old questionaire
      questions.questions.firstWhereOrNull((q) => q.id == property)!.prompt;
}
