import 'package:studyu_core/core.dart';

class DeferredFitbitQuestionRequest {
  DeferredFitbitQuestionRequest({
    required this.questionId,
    required this.answerTimestamp,
    required this.windowEnd,
    required this.windowStarts,
  });

  factory DeferredFitbitQuestionRequest.fromJson(Map<String, dynamic> json) {
    return DeferredFitbitQuestionRequest(
      questionId: json['questionId'] as String,
      answerTimestamp: DateTime.parse(json['answerTimestamp'] as String),
      windowEnd: DateTime.parse(json['windowEnd'] as String),
      windowStarts: (json['windowStarts'] as Map<String, dynamic>).map(
        (type, start) => MapEntry(
          FitbitQuestionType.fromJson(type),
          DateTime.parse(start as String),
        ),
      ),
    );
  }

  final String questionId;
  final DateTime answerTimestamp;
  final DateTime windowEnd;
  final Map<FitbitQuestionType, DateTime> windowStarts;

  List<FitbitQuestionType> get types => windowStarts.keys.toList();

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'answerTimestamp': answerTimestamp.toIso8601String(),
    'windowEnd': windowEnd.toIso8601String(),
    'windowStarts': windowStarts.map(
      (type, start) => MapEntry(type.toJson(), start.toIso8601String()),
    ),
  };
}

class DeferredFitbitRequest {
  DeferredFitbitRequest({
    required this.subjectId,
    required this.studyId,
    required this.taskId,
    required this.interventionId,
    required this.periodId,
    required this.completedAt,
    required this.questionnaireAnswers,
    required this.questions,
  });

  factory DeferredFitbitRequest.fromJson(Map<String, dynamic> json) {
    return DeferredFitbitRequest(
      subjectId: json['subjectId'] as String,
      studyId: json['studyId'] as String,
      taskId: json['taskId'] as String,
      interventionId: json['interventionId'] as String,
      periodId: json['periodId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      questionnaireAnswers: (json['questionnaireAnswers'] as List)
          .map((answer) => Map<String, dynamic>.from(answer as Map))
          .toList(),
      questions: (json['questions'] as List)
          .map(
            (question) => DeferredFitbitQuestionRequest.fromJson(
              Map<String, dynamic>.from(question as Map),
            ),
          )
          .toList(),
    );
  }

  final String subjectId;
  final String studyId;
  final String taskId;
  final String interventionId;
  final String periodId;
  final DateTime completedAt;
  final List<Map<String, dynamic>> questionnaireAnswers;
  final List<DeferredFitbitQuestionRequest> questions;

  String get id =>
      '$subjectId:$interventionId:$taskId:$periodId:${completedAt.toUtc().toIso8601String()}';

  Map<String, dynamic> toJson() => {
    'subjectId': subjectId,
    'studyId': studyId,
    'taskId': taskId,
    'interventionId': interventionId,
    'periodId': periodId,
    'completedAt': completedAt.toIso8601String(),
    'questionnaireAnswers': questionnaireAnswers,
    'questions': questions.map((question) => question.toJson()).toList(),
  };
}
