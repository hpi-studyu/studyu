import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class DateQuestionWidget extends QuestionWidget {
  final DateQuestion question;
  final Function(Answer)? onDone;

  const DateQuestionWidget({super.key, required this.question, this.onDone});

  @override
  State<DateQuestionWidget> createState() => _DateQuestionWidgetState();
}

class _DateQuestionWidgetState extends State<DateQuestionWidget> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: widget.question.minDate ?? DateTime(1900),
      lastDate: widget.question.maxDate ?? DateTime(2100),
      helpText: widget.question.prompt,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });

      // If time is required, pick time next
      if (widget.question.includeTime && mounted) {
        await _pickTime();
      }
    }
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final initialTime = _selectedDate != null
        ? TimeOfDay.fromDateTime(_selectedDate!)
        : now;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: widget.question.prompt,
    );

    if (pickedTime != null && _selectedDate != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
  }

  void _handleSubmit() {
    if (_selectedDate != null) {
      widget.onDone?.call(widget.question.constructAnswer(_selectedDate!));
    }
  }

  String _formatDate(DateTime date) {
    try {
      final format = DateFormat(widget.question.dateFormat);
      return format.format(date);
    } catch (e) {
      // Fallback to default format if custom format fails
      return widget.question.includeTime
          ? DateFormat('yyyy-MM-dd HH:mm').format(date)
          : DateFormat('yyyy-MM-dd').format(date);
    }
  }

  String? _validateDate(DateTime? date) {
    if (date == null) {
      return AppLocalizations.of(context)!.date_picker_validation_required;
    }

    if (widget.question.minDate != null &&
        date.isBefore(widget.question.minDate!)) {
      return AppLocalizations.of(
        context,
      )!.date_picker_validation_min_date(_formatDate(widget.question.minDate!));
    }

    if (widget.question.maxDate != null &&
        date.isAfter(widget.question.maxDate!)) {
      return AppLocalizations.of(
        context,
      )!.date_picker_validation_max_date(_formatDate(widget.question.maxDate!));
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    final validationError = _validateDate(_selectedDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Date picker button
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_today),
          label: Text(
            _selectedDate != null
                ? _formatDate(_selectedDate!)
                : (widget.question.includeTime
                      ? localizations.date_time_picker_button_label
                      : localizations.date_picker_button_label),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            alignment: Alignment.centerLeft,
          ),
        ),

        // Time picker button (if includeTime is true and date is selected)
        if (widget.question.includeTime && _selectedDate != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.access_time),
            label: Text(TimeOfDay.fromDateTime(_selectedDate!).format(context)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              alignment: Alignment.centerLeft,
            ),
          ),
        ],

        // Validation error message
        if (validationError != null) ...[
          const SizedBox(height: 8),
          Text(
            validationError,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Clear button (only show if date is selected)
            if (_selectedDate != null) ...[
              TextButton.icon(
                onPressed: _clearDate,
                icon: const Icon(Icons.clear),
                label: Text(localizations.date_picker_clear),
              ),
              const SizedBox(width: 8),
            ],
            // Submit button
            OutlinedButton(
              onPressed: _selectedDate != null ? _handleSubmit : null,
              child: Text(localizations.submit),
            ),
          ],
        ),
      ],
    );
  }
}
