import 'package:collection/collection.dart';

import 'question.dart';

class ChoiceQuestion extends Question {
  static String questionType = Question.registerQuestionType('choice', (data) => ChoiceQuestion.fromJson(data));
  @override
  String get type => questionType;

  static const String keyMultiple = 'multiple';
  bool multiple;

  static const String keyChoices = 'choices';
  List<Choice> choices;

  ChoiceQuestion.fromJson(Map<String, dynamic> data) : super.fromJson(data) {
    multiple = data[keyMultiple];
    choices = (data[keyChoices] as List).map((choice) => Choice.fromJson(choice)).toList();
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
    keyMultiple: multiple,
    keyChoices: choices.map((choice) => choice.toJson()).toList()
  });
}

class Choice {
  static const String keyID = 'id';
  String id;

  static const String keyText = 'text';
  String text;

  Choice.fromJson(Map<String, dynamic> data) {
    id = data[keyID];
    text = data[keyText];
  }

  Map<String, dynamic> toJson() => {
    keyID: id,
    keyText: text
  };

  @override
  String toString() => toJson().toString();
}
