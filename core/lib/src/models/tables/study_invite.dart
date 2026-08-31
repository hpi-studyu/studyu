import 'package:json_annotation/json_annotation.dart';

import 'package:studyu_core/core.dart';
import 'package:studyu_core/src/util/supabase_object.dart';

part 'study_invite.g.dart';

@JsonSerializable()
class StudyInvite extends SupabaseObjectFunctions<StudyInvite> {
  static const String tableName = 'study_invite';
  static const String participantCountJsonKey =
      'study_invite_participant_count';

  @override
  Map<String, Object> get primaryKeys => {'code': code};

  String code;
  @JsonKey(name: 'study_id')
  String studyId;
  @JsonKey(name: 'preselected_intervention_ids')
  List<String>? preselectedInterventionIds;
  @JsonKey(name: participantCountJsonKey, includeToJson: false)
  int participantCount;

  StudyInvite(
    this.code,
    this.studyId, {
    this.preselectedInterventionIds,
    this.participantCount = 0,
  });

  factory StudyInvite.fromJson(Map<String, dynamic> json) =>
      _$StudyInviteFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$StudyInviteToJson(this);
}
