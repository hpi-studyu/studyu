import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_designer_v2/domain/study.dart';

Map<StudyActionType, IconData> studyActionIcons = {
  StudyActionType.pin: MdiIcons.pin,
  StudyActionType.pinoff: MdiIcons.pinOff,
  StudyActionType.edit: Icons.edit_rounded,
  StudyActionType.duplicate: Icons.file_copy_rounded,
  StudyActionType.duplicateDraft: Icons.file_copy_rounded,
  StudyActionType.addCollaborator: Icons.person_add_rounded,
  StudyActionType.export: Icons.download_rounded,
  StudyActionType.delete: Icons.delete_rounded,
  StudyActionType.createTemplateTrial: Icons.add_rounded,
  StudyActionType.view: Icons.visibility_rounded,
};
