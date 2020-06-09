import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'question.dart';

part 'answer.g.dart';

@JsonSerializable()
class Answer<V> {
  static const String answerType = null;
  String get type => answerType;

  String question;
  DateTime timestamp;

  static const String keyResponse = 'response';
  @JsonKey(ignore: true)
  V response;

  Answer(this.question, this.timestamp);

  Answer.forQuestion(Question question, this.response) : question = question.id, timestamp = DateTime.now();

  factory Answer.parseJson(Map<String, dynamic> json) => _$AnswerFromJson(json)..response = json[keyResponse] as V;
  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(_$AnswerToJson(this), { keyResponse: response });

  static Answer fromJson(Map<String, dynamic> data) {
    dynamic value = data[keyResponse];
    switch (value.runtimeType) {
      case bool:
        return Answer<bool>.parseJson(data);
      case int:
        return Answer<int>.parseJson(data);
      case String:
        return Answer<String>.parseJson(data);
      default:
        if (value is List<String>) {
          return Answer<List<String>>.parseJson(data);
        } else {
          throw ArgumentError('Unknown answer type: ${value.runtimeType}');
        }
    }
  }

  @override
  String toString() {
    return toJson().toString();
  }
}