import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/util/supabase_object.dart';

part 'tag.g.dart';

@JsonSerializable()
class Tag extends SupabaseObjectFunctions<Tag> {
  static const String tableName = 'tag';

  @override
  Map<String, dynamic> get primaryKeys => {'id': id};

  @JsonKey(name: 'id')
  String id;
  @JsonKey(name: 'name')
  String name;

  Tag({required this.id, required this.name});

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TagToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Tag && id == other.id && name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
