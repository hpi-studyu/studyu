import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_controller.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/theme.dart';

class DateQuestionFormView extends ConsumerWidget {
  const DateQuestionFormView({required this.formViewModel, super.key});

  final QuestionFormViewModel formViewModel;

  String _formatDate(DateTime date, DateFormatPreset preset) {
    try {
      final format = DateFormat(preset.pattern);
      return format.format(date);
    } catch (e) {
      return date.toIso8601String();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ReactiveFormConsumer(
      builder: (context, formGroup, child) {
        final preset =
            formViewModel.dateFormatPresetControl.value ??
            DateFormatPreset.isoDate;
        final includesTime = preset.includesTime;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Format Preset
            generateRow(
              label: "asd",
              labelHelpText: "asd",
              input: ReactiveDropdownField<DateFormatPreset>(
                formControl: formViewModel.dateFormatPresetControl,
                items: DateFormatPreset.values.map((preset) {
                  final exampleDate = DateTime(2024, 12, 31, 14, 30);
                  final example = _formatDate(exampleDate, preset);
                  return DropdownMenuItem(
                    value: preset,
                    child: Text('${preset.pattern} ($example)'),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Min Date
            generateRow(
              label: AppLocalizations.of(context)!.date_min_date_label,
              labelHelpText: AppLocalizations.of(
                context,
              )!.date_min_date_label_helper,
              input: PointerInterceptor(
                child: ReactiveDatePickerField(
                  formControl: formViewModel.dateMinControl,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  placeholder: AppLocalizations.of(context)!.date_picker_hint,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Max Date
            generateRow(
              label: AppLocalizations.of(context)!.date_max_date_label,
              labelHelpText: AppLocalizations.of(
                context,
              )!.date_max_date_label_helper,
              input: PointerInterceptor(
                child: ReactiveDatePickerField(
                  formControl: formViewModel.dateMaxControl,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  placeholder: AppLocalizations.of(context)!.date_picker_hint,
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Initial Date
            generateRow(
              label: AppLocalizations.of(context)!.date_initial_value_label,
              labelHelpText: AppLocalizations.of(
                context,
              )!.date_initial_value_label_helper,
              input: PointerInterceptor(
                child: ReactiveDatePickerField(
                  formControl: formViewModel.dateInitialValueControl,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  placeholder: AppLocalizations.of(context)!.date_picker_hint,
                ),
              ),
            ),
            const SizedBox(height: 24.0),

            // Preview section
            const Divider(thickness: 2.0),
            const SizedBox(height: 16.0),
            Text(
              AppLocalizations.of(context)!.date_preview_label,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8.0),
            TextParagraph(
              text: AppLocalizations.of(context)!.date_preview_helper,
              style: ThemeConfig.bodyTextMuted(theme),
            ),
            const SizedBox(height: 16.0),
            _buildPreview(context, preset, includesTime),
          ],
        );
      },
    );
  }

  Widget _buildPreview(
    BuildContext context,
    DateFormatPreset preset,
    bool includesTime,
  ) {
    final theme = Theme.of(context);
    final exampleDate = DateTime(2024, 12, 31, 14, 30);
    final formattedDate = _formatDate(exampleDate, preset);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker button preview
          OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.calendar_today),
            label: Text(formattedDate),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              alignment: Alignment.centerLeft,
            ),
          ),
          if (includesTime) ...[
            const SizedBox(height: 8.0),
            OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.access_time),
              label: Text(TimeOfDay.fromDateTime(exampleDate).format(context)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                alignment: Alignment.centerLeft,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget generateRow({
    required String label,
    required String labelHelpText,
    required Widget input,
  }) {
    return Row(
      children: [
        Flexible(
          flex: 5,
          child: FormTableLayout(
            rowLayout: FormTableRowLayout.vertical,
            rows: [
              FormTableRow(
                label: label,
                labelHelpText: labelHelpText,
                input: input,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Custom reactive date picker field
class ReactiveDatePickerField extends StatelessWidget {
  const ReactiveDatePickerField({
    required this.formControl,
    required this.firstDate,
    required this.lastDate,
    this.placeholder,
    super.key,
  });

  final FormControl<DateTime?> formControl;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? placeholder;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = formControl.value ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate)
          ? firstDate
          : initialDate.isAfter(lastDate)
          ? lastDate
          : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      formControl.value = pickedDate;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return ReactiveValueListenableBuilder<DateTime?>(
      formControl: formControl,
      builder: (context, control, child) {
        final value = control.value;

        return InkWell(
          onTap: () => _pickDate(context),
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: placeholder,
              suffixIcon: value != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => formControl.value = null,
                    )
                  : const Icon(Icons.calendar_today),
            ),
            child: value != null
                ? Text(_formatDate(value))
                : Text(
                    placeholder ?? '',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
          ),
        );
      },
    );
  }
}
