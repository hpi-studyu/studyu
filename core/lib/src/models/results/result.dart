import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';

part 'result.g.dart';

@JsonSerializable()
class Result<T> {
  static const keyType = 'type';
  String type;
  // Todo make non-nullable (breaks backwards compatibility)
  String? periodId;

  static const String keyResult = 'result';
  @JsonKey(includeToJson: false, includeFromJson: false)
  late T result;

  Result(this.type);

  Result.app({required this.type, required this.periodId, required this.result});

  factory Result.parseJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  factory Result.fromJson(Map<String, dynamic> json) => _fromJson(json) as Result<T>;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> resultMap = switch (result) {
      final QuestionnaireState questionnaireState => {keyResult: questionnaireState.toJson()},
      bool() => {keyResult: result},
      _ => {keyResult: _getUnsupportedResult()}
    };
    return mergeMaps<String, dynamic>(_$ResultToJson(this), resultMap);
  }

  String _getUnsupportedResult() {
    print('Unsupported question type: $T');
    return '';
  }

  static Result _fromJson(Map<String, dynamic> data) {
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
