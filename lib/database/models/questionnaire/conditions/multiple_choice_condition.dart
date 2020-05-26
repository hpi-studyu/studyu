import 'package:collection/collection.dart';

import '../answers/answer.dart';
import '../answers/multiple_choice_answer.dart';
import '../questions/multiple_choice_question.dart';
import 'condition.dart';

class MultipleChoiceCondition extends Condition {

  static const String conditionType = MultipleChoiceQuestion.questionType;
  @override
  String get type => conditionType;

  Set<int> choiceIds;

  MultipleChoiceCondition(int questionId, this.choiceIds) : super(questionId);

  MultipleChoiceCondition.fromJson(Map<String, dynamic> data) : super.fromJsonScaffold(data) {
    choiceIds = data['choiceIds'];
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
        'choiceIds': choiceIds
      });

  @override
  bool checkAnswer(Answer answer) {
    return super.checkAnswer(answer) && (answer as MultipleChoiceAnswer).choices?.map((choice) => choice.id)?.toSet() == choiceIds;
  }
}
