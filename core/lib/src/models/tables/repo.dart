import 'package:json_annotation/json_annotation.dart';

import '../../../core.dart';
import '../../util/supabase_object.dart';

part 'repo.g.dart';

enum GitProvider { gitlab }

@JsonSerializable()
class Repo extends SupabaseObjectFunctions<Repo> {
  static const String tableName = 'repo';

  @override
  Map<String, dynamic> get primaryKeys => {'project_id': projectId};

  @JsonKey(name: 'project_id')
  String projectId;
  @JsonKey(name: 'user_id')
  String userId;
  @JsonKey(name: 'study_id')
  String studyId;
  GitProvider provider;
  @JsonKey(name: 'web_url')
  String webUrl;
  @JsonKey(name: 'git_url')
  String gitUrl;

  Repo(this.projectId, this.userId, this.studyId, this.provider, this.webUrl, this.gitUrl);

  factory Repo.fromJson(Map<String, dynamic> json) => _$RepoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepoToJson(this);
}
