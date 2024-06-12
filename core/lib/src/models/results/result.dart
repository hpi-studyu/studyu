import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/src/models/questionnaire/questionnaire_state.dart';
import 'package:studyu_core/src/models/unknown_json_type_error.dart';

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

  Result.app(
      {required this.type, required this.periodId, required this.result});

  factory Result.parseJson(Map<String, dynamic> json) => _$ResultFromJson(json);

  factory Result.fromJson(Map<String, dynamic> json) => switch (json[keyType]) {
        'QuestionnaireState' => Result<QuestionnaireState>.parseJson(json)
          ..result = QuestionnaireState.fromJson(
              List<Map<String, dynamic>>.from(json[keyResult] as List)),
        'bool' => Result<bool>.parseJson(json)
          ..result = json[keyResult] as bool,
        _ => throw UnknownJsonTypeError(json[keyType]),
      } as Result<T>;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> resultMap = switch (type) {
      'QuestionnaireState' => {
          keyResult: (result as QuestionnaireState).toJson()
        },
      'bool' => {keyResult: result},
      _ => throw ArgumentError('Unknown result type $type'),
    };
    return mergeMaps<String, dynamic>(_$ResultToJson(this), resultMap);
  }
}
