import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/question.dart';

part 'answer.g.dart';

@JsonSerializable()
class Answer<V> {
  String question;
  DateTime timestamp;

  static const String keyResponse = 'response';
  @JsonKey(includeToJson: false, includeFromJson: false)
  late V response;

  Answer(this.question, this.timestamp);

  Answer.forQuestion(Question question, this.response)
    : question = question.id,
      timestamp = DateTime.now();

  static const String keyResponseType = 'responseType';

  factory Answer.parseJson(Map<String, dynamic> json) =>
      _$AnswerFromJson(json)..response = json[keyResponse] as V;

  Map<String, dynamic> toJson() {
    final dynamic encodableResponse = response is DateTime
        ? (response as DateTime).toIso8601String()
        : response;
    return mergeMaps<String, dynamic>(_$AnswerToJson(this), {
      keyResponse: encodableResponse,
      if (response is DateTime) keyResponseType: 'DateTime',
    });
  }

  static Answer fromJson(Map<String, dynamic> data) {
    final dynamic value = data[keyResponse];
    final String? responseType = data[keyResponseType] as String?;

    if (responseType == 'DateTime') {
      return Answer<DateTime>(
        data['question'] as String,
        DateTime.parse(data['timestamp'] as String),
      )..response = DateTime.parse(value as String);
    }

    switch (value) {
      case bool():
        return Answer<bool>.parseJson(data);
      case num():
        return Answer<num>.parseJson(data);
      case String():
        return Answer<String>.parseJson(data);
      default:
        // todo Why does value has a type of List<dynamic> instead of List<String>?
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
