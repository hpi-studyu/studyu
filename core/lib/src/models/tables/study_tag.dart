import 'package:json_annotation/json_annotation.dart';
import 'package:studyu_core/core.dart';

part 'study_tag.g.dart';

@JsonSerializable()
class StudyTag extends SupabaseObjectFunctions<StudyTag> {
  static const String tableName = 'study_tag';

  @override
  Map<String, dynamic> get primaryKeys => {'tag_id': tagId, 'study_id': studyId};

  @JsonKey(name: 'study_id')
  final String studyId;
  @JsonKey(name: 'tag_id')
  final String tagId;

  @JsonKey(includeToJson: false, includeFromJson: false)
  late Tag tag;

  /*@JsonKey(includeToJson: false, includeFromJson: false)
  late Study study;*/

  StudyTag({
    required this.studyId,
    required this.tagId,
  });

  StudyTag.fromTag({
    required this.tag,
    required this.studyId,
  }) : tagId = tag.id;

  factory StudyTag.fromJson(Map<String, dynamic> json) {
    final studyTag = _$StudyTagFromJson(json);

    /*final Map<String, dynamic>? study = json['study'] as Map<String, dynamic>?;
    if (study != null) {
      studyTag.study = Study.fromJson(study);
    }*/

    final Map<String, dynamic>? tag = json['tag'] as Map<String, dynamic>?;
    if (tag != null) {
      studyTag.tag = Tag.fromJson(tag);
    }

    return studyTag;
  }

  String get name => tag.name;

  String? get color => tag.color;

  String get id => tag.id;

  @override
  Map<String, dynamic> toJson() => _$StudyTagToJson(this);

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StudyTag && studyId == other.studyId && tag == other.tag;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ studyId.hashCode ^ tag.hashCode;
}

extension StudyTagListToTagList on List<StudyTag> {
  List<Tag> toTagList() => map((studyTag) => studyTag.tag).toList();
}
