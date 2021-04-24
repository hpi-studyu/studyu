import 'package:json_annotation/json_annotation.dart';

import '../../../core.dart';
import '../../util/supabase_object.dart';

part 'repo.g.dart';

enum GitProvider { gitlab }

@JsonSerializable()
class Repo extends SupabaseObjectFunctions<Repo> {
  static const String tableName = 'repo';

  @override
  Map<String, dynamic> get primaryKeys => {'projectId': projectId};

  String projectId;
  String userId;
  String studyId;
  GitProvider provider;

  Repo(this.projectId, this.userId, this.studyId, this.provider);

  factory Repo.fromJson(Map<String, dynamic> json) => _$RepoFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$RepoToJson(this);
}
