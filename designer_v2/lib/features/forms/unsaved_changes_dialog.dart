import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:studyu_designer_v2/common_views/confirmation_dialog.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return PointerInterceptor(
      child: StandardConfirmationDialog(
        title: tr.dialog_unsaved_changes_title,
        message: tr.dialog_unsaved_changes_description,
        actions: [
          ConfirmationDialogAction(
            label: tr.dialog_action_unsaved_changes_stay,
            onPressed: () => Navigator.pop(context, false),
          ),
          ConfirmationDialogAction(
            label: tr.dialog_action_unsaved_changes_discard,
            isDestructive: true,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }
}
