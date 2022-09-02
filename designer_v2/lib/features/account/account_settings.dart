import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/localization/language_picker.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class AccountSettingsDialog extends ConsumerWidget {
  const AccountSettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StandardDialog(
      titleText: "Account settings".hardcoded,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          FormTableLayout(
            rowLayout: FormTableRowLayout.horizontal,
            rows: [
              FormTableRow(
                label: "Language",
                input: const Align(
                    alignment: Alignment.centerRight,
                    child: LanguagePicker()
                ),
              ),
            ],
          ),
        ],
      ),
      actionButtons: [DismissButton(text: "Close".hardcoded)],
      minWidth: 650,
      maxWidth: 750,
      minHeight: 450,
    );
  }
}
