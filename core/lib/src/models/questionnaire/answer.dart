import 'package:studyu_core/src/models/medication/medication_answer.dart';
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

  new(this.question, this.timestamp);

  new forQuestion(Question question, this.response)
    : question = question.id,
      timestamp = DateTime.now();

  static const String keyResponseType = 'responseType';

  factory parseJson(Map<String, dynamic> json) =>
      _$AnswerFromJson(json)..response = json[keyResponse] as V;

  Map<String, dynamic> toJson() {
    final dynamic encodableResponse = response is DateTime
        ? (response as DateTime).toIso8601String()
        : response is MedicationAnswer
        ? (response as MedicationAnswer).toJson()
        : response;
    return mergeMaps<String, dynamic>(_$AnswerToJson(this), {
      keyResponse: encodableResponse,
      if (response is DateTime) keyResponseType: 'DateTime',
      if (response is MedicationAnswer) keyResponseType: 'MedicationAnswer',
    });
  }

  static Answer fromJson(Map<String, dynamic> data) {
    final dynamic value = data[keyResponse];
    final String? responseType = data[keyResponseType] as String?;

    if (responseType == 'MedicationAnswer' && value is Map) {
      return Answer<MedicationAnswer>(
        data['question'] as String,
        DateTime.parse(data['timestamp'] as String),
      )..response = MedicationAnswer.fromJson(
          Map<String, dynamic>.from(value),
        );
    }

    if (responseType == 'DateTime') {
      return Answer<DateTime>(
        data['question'] as String,
        DateTime.parse(data['timestamp'] as String),
      )..response = DateTime.parse(value as String);
    }

    // Fallback: a String value that parses as ISO 8601 was likely written by
    // an older version that serialised DateTime without the responseType key.
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return Answer<DateTime>(
          data['question'] as String,
          DateTime.parse(data['timestamp'] as String),
        )..response = parsed;
      }
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
