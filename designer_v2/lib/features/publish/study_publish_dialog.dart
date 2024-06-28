import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/dialogs/publish/study_publish_dialog_confirm.dart';
import 'package:studyu_designer_v2/features/dialogs/publish/study_publish_dialog_success.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';
import 'package:studyu_designer_v2/theme.dart';

class PublishDialog extends StudyPageWidget {
  const PublishDialog(super.studyCreationArgs, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyCreationArgs));

    if (state.isPublished) {
      return PublishSuccessDialog(studyCreationArgs);
    }
    return PublishConfirmationDialog(studyCreationArgs);
  }
}

showPublishDialog(BuildContext context, StudyCreationArgs studyCreationArgs) {
  final theme = Theme.of(context);
  return showDialog(
    context: context,
    barrierColor: ThemeConfig.modalBarrierColor(theme),
    builder: (context) => PublishDialog(studyCreationArgs),
  );
}
