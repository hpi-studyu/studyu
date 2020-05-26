import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'question.dart';

class MultipleChoiceQuestion extends Question {

  static const String questionType = 'multiple';
  @override
  String get type => questionType;

  bool multiple;
  List<Choice> choices;

  MultipleChoiceQuestion(int id, String question, this.choices, {@required this.multiple}) : super(id, question);

  MultipleChoiceQuestion.fromJson(Map<String, dynamic> data) : super.fromJsonScaffold(data) {
    multiple = data['multiple'];
    choices = (data['choices'] as List).map((choice) => Choice.fromJson(choice)).toList();
  }

  @override
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(super.toJson(), {
        'multiple': multiple,
        'choices': choices.map((choice) => choice.toJson()).toList()
      });
}

class Choice {
  int id;
  String value;

  Choice(this.id, this.value);

  Choice.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    value = data['value'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'value': value
      };
}
