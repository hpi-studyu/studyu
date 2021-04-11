// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer<V> _$AnswerFromJson<V>(Map<String, dynamic> json) {
  return Answer<V>(
    json['question'] as String,
    // Keep .toString() until fixed: https://github.com/google/json_serializable.dart/issues/656
    DateTime.parse(json['timestamp'].toString()),
  );
}

Map<String, dynamic> _$AnswerToJson<V>(Answer<V> instance) => <String, dynamic>{
      'question': instance.question,
      'timestamp': instance.timestamp.toIso8601String(),
    };
