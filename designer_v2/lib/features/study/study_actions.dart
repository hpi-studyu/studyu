import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/domain/study.dart';

Map<StudyActionType, IconData> studyActionIcons = {
  StudyActionType.edit: Icons.edit_rounded,
  StudyActionType.duplicate: Icons.content_copy_rounded,
  StudyActionType.addCollaborator: Icons.person_add_rounded,
  StudyActionType.recruit: Icons.send_rounded,
  StudyActionType.export: Icons.download_rounded,
  StudyActionType.delete: Icons.delete_rounded,
};
