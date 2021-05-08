import 'package:json_annotation/json_annotation.dart';

import '../../../core.dart';
import '../../util/supabase_object.dart';

part 'study_token.g.dart';

@JsonSerializable()
class StudyToken extends SupabaseObjectFunctions<StudyToken> {
  static const String tableName = 'study_token';

  @override
  Map<String, dynamic> get primaryKeys => {'token': token};

  String token;
  String studyId;

  StudyToken(this.token, this.studyId);

  factory StudyToken.fromJson(Map<String, dynamic> json) => _$StudyTokenFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyTokenToJson(this);
}
