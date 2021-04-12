import 'package:collection/collection.dart';
import 'package:fhir/r4.dart' as fhir;
import 'package:json_annotation/json_annotation.dart';

import '../questionnaire/questionnaire_state.dart';

part 'result.g.dart';

@JsonSerializable()
class Result<T> {
  String/*!*/ taskId;
  DateTime/*!*/ timeStamp;
  static const keyType = 'type';
  String/*!*/ type;

  static const String keyResult = 'result';
  @JsonKey(ignore: true)
  T/*!*/ result;

  Result();

  Result.app({this.type, this.result, this.taskId}) : timeStamp = DateTime.now();

  factory Result.parseJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> resultMap;
    switch (type) {
      case 'QuestionnaireState':
        resultMap = {keyResult: (result as QuestionnaireState).toJson()};
        break;
      case 'fhir.QuestionnaireResponse':
        resultMap = {keyResult: (result as fhir.QuestionnaireResponse).toJson()};
        break;
      case 'bool':
        resultMap = {keyResult: result};
        break;
      default:
        print('Unsupported question type: $type');
        resultMap = {keyResult: ''};
    }
    return mergeMaps<String, dynamic>(_$ResultToJson(this), resultMap);
  }

  static Result fromJson(Map<String, dynamic> data) {
    switch (data[keyType] as String/*!*/) {
      case 'fhir.QuestionnaireResponse':
        return Result<fhir.QuestionnaireResponse>.parseJson(data)
          ..result = fhir.QuestionnaireResponse.fromJson(data[keyResult] as Map<String, dynamic>);
      case 'QuestionnaireState':
        return Result<QuestionnaireState>.parseJson(data)
          ..result = QuestionnaireState.fromJson(List<Map<String, dynamic>>.from(data[keyResult] as List));
      case 'bool':
        return Result<bool/*!*/>.parseJson(data)..result = data[keyResult] as bool;
      default:
        throw ArgumentError('Type ${data[keyType]} not supported.');
    }
  }
}
