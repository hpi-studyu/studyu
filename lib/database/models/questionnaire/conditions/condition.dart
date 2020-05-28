import '../answers/answer.dart';
import 'multiple_choice_condition.dart';

class Condition {
  static const conditionType = null;
  String get type => conditionType;

  int questionId;

  Condition(this.questionId);

  Condition.fromJsonScaffold(Map<String, dynamic> data) {
    questionId = data['questionId'];
  }

  factory Condition.fromJson(Map<String, dynamic> data) {
    if (!data.containsKey('type')) throw 'Missing condition type!';
    switch (data['type']) {
      case MultipleChoiceCondition.conditionType:
        return MultipleChoiceCondition.fromJson(data);
      default:
        throw 'Unknown condition type!';
    }
  }

  Map<String, dynamic> toJson() => {'questionId': questionId, 'type': type};

  @override
  String toString() {
    return toJson().toString();
  }

  bool checkAnswer(Answer answer) {
    return answer.type == type;
  }
}
