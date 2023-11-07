import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return StandardDialog(
      titleText: tr.dialog_unsaved_changes_title,
      body: TextParagraph(
        text: tr.dialog_unsaved_changes_description,
      ),
      actionButtons: [
        PrimaryButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          text: tr.dialog_action_unsaved_changes_stay,
          icon: null,
        ),
        SecondaryButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          text: tr.dialog_action_unsaved_changes_discard,
          icon: null,
        ),
      ],
      maxWidth: 500,
      minHeight: 225,
    );
  }
}
