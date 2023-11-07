import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/publish/study_publish_dialog_confirm.dart';
import 'package:studyu_designer_v2/features/publish/study_publish_dialog_success.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/theme.dart';

class PublishDialog extends StudyPageWidget {
  const PublishDialog(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    if (state.isPublished) {
      return PublishSuccessDialog(studyId);
    }
    return PublishConfirmationDialog(studyId);
  }
}

showPublishDialog(BuildContext context, StudyID studyId) {
  final theme = Theme.of(context);
  return showDialog(
    context: context,
    barrierColor: ThemeConfig.modalBarrierColor(theme),
    builder: (context) => PublishDialog(studyId),
  );
}
