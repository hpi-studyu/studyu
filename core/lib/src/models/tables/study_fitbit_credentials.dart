import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'study_fitbit_credentials.g.dart';

@JsonSerializable()
class StudyFitbitCredentials
    extends SupabaseObjectFunctions<StudyFitbitCredentials> {
  static const String tableName = 'study_fitbit_credentials';

  @override
  Map<String, Object> get primaryKeys => {'code': studyId};

  @JsonKey(name: 'study_id')
  String studyId;
  @JsonKey(name: 'fitbit_credentials')
  FitbitAuthCredentials fitbitCredentials;

  StudyFitbitCredentials(this.studyId, this.fitbitCredentials);

  factory StudyFitbitCredentials.fromJson(Map<String, dynamic> json) =>
      _$StudyFitbitCredentialsFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyFitbitCredentialsToJson(this);
}
