import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/util/supabase_object.dart';

part 'study_tag.g.dart';

@JsonSerializable()
class StudyTag extends SupabaseObjectFunctions<StudyTag> {
  static const String tableName = 'study_tag';

  @override
  Map<String, dynamic> get primaryKeys => {'id': id};

  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'name')
  String name;
  @JsonKey(name: 'color')
  String color;
  @JsonKey(name: 'parent_id')
  String? parentId;

  StudyTag(this.id, this.name, this.color, {this.parentId});

  factory StudyTag.fromJson(Map<String, dynamic> json) => _$StudyTagFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyTagToJson(this);

  @override
  String toString() => toJson().toString();
}
