import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyou_core/models/models.dart';

part "result.g.dart";

@JsonSerializable()
class Result<T> {
  String taskId;
  DateTime timeStamp;
  static const keyType = 'type';
  String type;

  static const String keyResult = 'result';
  @JsonKey(ignore: true)
  T result;

  Result();

  factory Result.parseJson(Map<String, dynamic> json) => _$ResultFromJson(json);
  Map<String, dynamic> toJson() {
    Map<String, dynamic> resultMap;
    switch (result.runtimeType) {
      case QuestionnaireState:
        resultMap = {keyResult: (result as QuestionnaireState).toJson()};
        break;
      default:
        resultMap = {keyResult: ''};
    }
    type = result.runtimeType.toString();
    return mergeMaps<String, dynamic>(_$ResultToJson(this), resultMap);
  }

  static Result fromJson(Map<String, dynamic> data) {
    switch (data[keyType]) {
      case 'QuestionnaireState':
        return Result<QuestionnaireState>.parseJson(data)
          ..result = QuestionnaireState.fromJson(
              data[keyResult].map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList());
      default:
        throw ArgumentError('Type ${data[keyType]} not supported.');
    }
  }
}
