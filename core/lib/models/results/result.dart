import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyou_core/models/models.dart';

part 'result.g.dart';

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
        type = 'QuestionnaireState';
        break;
      case bool:
        resultMap = {keyResult: result};
        type = 'bool';
        break;
      default:
        resultMap = {keyResult: ''};
    }
    return mergeMaps<String, dynamic>(_$ResultToJson(this), resultMap);
  }

  static Result fromJson(Map<String, dynamic> data) {
    switch (data[keyType] as String) {
      case 'QuestionnaireState':
        return Result<QuestionnaireState>.parseJson(data)
          ..result = QuestionnaireState.fromJson(List<Map<String, dynamic>>.from(data[keyResult] as List));
      case 'bool':
        return Result<bool>.parseJson(data)..result = data[keyResult] as bool;
      default:
        throw ArgumentError('Type ${data[keyType]} not supported.');
    }
  }
}
