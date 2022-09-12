import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class UnsavedChangesDialog extends StatelessWidget {
  const UnsavedChangesDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StandardDialog(
      titleText: 'Go back and discard changes?',
      body: TextParagraph(text: "There are unsaved changes that will be lost "
          "when you go back. If you want to keep your changes, you need to "
          "save your work before going back.".hardcoded),
      actionButtons: [
        PrimaryButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          text: 'Stay',
          icon: null,
        ),
        SecondaryButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          text: 'Discard changes',
          icon: null,
        ),
      ],
      maxWidth: 500,
      minHeight: 225,
    );
  }
}
