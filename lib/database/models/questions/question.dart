import 'multiple_choice.dart';

class Question {
  static const String type = null;

  int id;
  String question;

  Question(this.id, this.question);

  Question.fromJsonScaffold(Map<String, dynamic> data) {
    id = data['id'];
    question = data['question'];
  }

  factory Question.fromJson(Map<String, dynamic> data) {
    if (!data.containsKey('type')) throw 'Missing question type!';
    switch (data['type']) {
      case MultipleChoiceQuestion.type:
        return MultipleChoiceQuestion.fromJson(data);
      default:
        throw 'Unknown question type!';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'type': type
      };

  @override
  String toString() {
    return '(${super.toString()} id: $id, question: $question)';
  }
}
