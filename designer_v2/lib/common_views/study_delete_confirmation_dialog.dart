import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class StudyDeleteConfirmationDialog extends StatefulWidget {
  const StudyDeleteConfirmationDialog({
    required this.study,
    required this.confirmLabel,
    super.key,
  });

  final Study study;
  final String confirmLabel;

  @override
  State<StudyDeleteConfirmationDialog> createState() =>
      _StudyDeleteConfirmationDialogState();
}

class _StudyDeleteConfirmationDialogState
    extends State<StudyDeleteConfirmationDialog> {
  final TextEditingController _studyTitleController = TextEditingController();
  bool _hasReadWarning = false;

  String get _studyTitle => widget.study.title ?? '';

  bool get _canDelete =>
      _hasReadWarning && _studyTitleController.text.trim() == _studyTitle;

  @override
  void initState() {
    super.initState();
    _studyTitleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _studyTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return StandardDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: colorScheme.error),
          const SizedBox(width: 8),
          Flexible(child: Text(tr.dialog_study_delete_title)),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle.merge(
                style: TextStyle(color: colorScheme.onErrorContainer),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr.dialog_study_delete_warning_heading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(tr.dialog_study_delete_warning_intro),
                    const SizedBox(height: 12),
                    _WarningBullet(
                      title: tr.dialog_study_delete_warning_study_title,
                      body: tr.dialog_study_delete_warning_study_body,
                    ),
                    _WarningBullet(
                      title: tr.dialog_study_delete_warning_participants_title,
                      body: tr.dialog_study_delete_warning_participants_body,
                    ),
                    _WarningBullet(
                      title: tr.dialog_study_delete_warning_data_title,
                      body: tr.dialog_study_delete_warning_data_body,
                    ),
                    _WarningBullet(
                      title: tr
                          .dialog_study_delete_warning_past_participants_title,
                      body:
                          tr.dialog_study_delete_warning_past_participants_body,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr.dialog_study_delete_warning_irreversible,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              key: const ValueKey('study_delete_read_warning_checkbox'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: _hasReadWarning,
              onChanged: (value) {
                setState(() {
                  _hasReadWarning = value ?? false;
                });
              },
              title: Text(tr.dialog_study_delete_read_confirmation),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr.dialog_study_delete_type_name_instruction(_studyTitle),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('study_delete_name_confirmation_field'),
            controller: _studyTitleController,
            decoration: InputDecoration(
              labelText: tr.dialog_study_delete_type_name_label,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actionButtons: [
        const DismissButton(),
        PrimaryButton(
          text: widget.confirmLabel,
          icon: null,
          enabled: _canDelete,
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      maxWidth: 650,
      minWidth: 560,
      minHeight: 0,
    );
  }
}

class _WarningBullet extends StatelessWidget {
  const _WarningBullet({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: body),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
