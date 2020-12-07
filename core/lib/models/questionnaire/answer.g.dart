// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer<V> _$AnswerFromJson<V>(Map<String, dynamic> json) {
  return Answer<V>(
    json['question'] as String,
    DateTime.parse(json['timestamp'].toString()),
  );
}

Map<String, dynamic> _$AnswerToJson<V>(Answer<V> instance) => <String, dynamic>{
      'question': instance.question,
      'timestamp': instance.timestamp.toIso8601String(),
    };
