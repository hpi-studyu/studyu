import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/dialogs/close/study_close_dialog_confirm.dart';
import 'package:studyu_designer_v2/features/dialogs/close/study_close_dialog_success.dart';
import 'package:studyu_designer_v2/features/dialogs/publish/study_publish_dialog_confirm.dart';
import 'package:studyu_designer_v2/features/dialogs/publish/study_publish_dialog_success.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/theme.dart';

enum StudyDialogType { publish, close }

class StudyDialog extends StudyPageWidget {
  final StudyDialogType dialogType;

  const StudyDialog(this.dialogType, super.studyCreationArgs, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyCreationArgs));

    switch (dialogType) {
      case StudyDialogType.publish:
        return state.isPublished
            ? PublishSuccessDialog(studyCreationArgs)
            : PublishConfirmationDialog(studyCreationArgs);
      case StudyDialogType.close:
        return state.isClosed
            ? CloseSuccessDialog(studyCreationArgs)
            : CloseConfirmationDialog(studyCreationArgs);
    }
  }
}

Future showStudyDialog(
  BuildContext context,
  StudyCreationArgs studyCreationArgs,
  StudyDialogType dialogType,
) {
  final theme = Theme.of(context);
  return showDialog(
    context: context,
    barrierColor: ThemeConfig.modalBarrierColor(theme),
    builder: (context) => StudyDialog(dialogType, studyCreationArgs),
  );
}
