import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_core/core.dart';

class DateQuestionWidget extends QuestionWidget {
  final DateQuestion question;
  final Function(Answer) onDone;

  const DateQuestionWidget({
    super.key,
    required this.question,
    required this.onDone,
  });

  @override
  State<DateQuestionWidget> createState() => _DateQuestionWidgetState();
}

class _DateQuestionWidgetState extends State<DateQuestionWidget> {
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = null;
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: widget.question.minDate ?? DateTime(1900),
      lastDate: widget.question.maxDate ?? now,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      widget.onDone(widget.question.constructAnswer(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          OutlinedButton(
            onPressed: () => _pickDate(context),
            child: Text(
              selectedDate != null
                  ? DateFormat.yMMMd().format(selectedDate!)
                  : 'Select Date', // TODO: Localize
            ),
          ),
        ],
      ),
    );
  }
}
