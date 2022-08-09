import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'question.dart';

part 'answer.g.dart';

@JsonSerializable()
class Answer<V> {
  String question;
  DateTime timestamp;

  static const String keyResponse = 'response';
  @JsonKey(ignore: true)
  late V response;

  Answer(this.question, this.timestamp);

  Answer.forQuestion(Question question, this.response)
      : question = question.id,
        timestamp = DateTime.now();

  factory Answer.parseJson(Map<String, dynamic> json) => _$AnswerFromJson(json)..response = json[keyResponse] as V;

  Map<String, dynamic> toJson() => mergeMaps<String, dynamic>(_$AnswerToJson(this), {keyResponse: response});

  static Answer fromJson(Map<String, dynamic> data) {
    final dynamic value = data[keyResponse];
    switch (value.runtimeType) {
      case bool:
        return Answer<bool>.parseJson(data);
      case num:
        return Answer<num>.parseJson(data);
      case int:
        return Answer<num>.parseJson(data);
      case double:
        return Answer<num>.parseJson(data);
      case String:
        return Answer<String>.parseJson(data);
      default:
        // todo Why is value List<dynamic> instead of List<String>?
        if (value is List) {
          data[keyResponse] = value.map((e) => e.toString()).toList();
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
