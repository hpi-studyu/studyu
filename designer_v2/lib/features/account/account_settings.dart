import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/language_picker.dart';

class AccountSettingsDialog extends ConsumerWidget {
  const AccountSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PointerInterceptor(
        child: StandardDialog(
      titleText: tr.navlink_account_settings,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          FormTableLayout(
            rowLayout: FormTableRowLayout.horizontal,
            rows: [
              FormTableRow(
                label: tr.language,
                input: const Align(alignment: Alignment.centerRight, child: LanguagePicker()),
              ),
            ],
          ),
        ],
      ),
      actionButtons: [DismissButton(text: tr.dialog_close)],
      minWidth: 650,
      maxWidth: 750,
      minHeight: 450,
    ));
  }
}
