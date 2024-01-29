import 'package:studyu_core/src/models/questionnaire/question.dart';

class UnknownQuestion extends Question<bool> {
  static const String questionType = 'unknown';
  UnknownQuestion() : super(questionType);

  @override
  bool get isSupported => false;

  @override
  Map<String, dynamic> toJson() {
    throw ArgumentError('UnknownQuestion should not be serialized');
  }
}
