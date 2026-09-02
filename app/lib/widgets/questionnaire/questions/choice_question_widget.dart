import 'package:flutter/material.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/widgets/questionnaire/questions/question_widget.dart';
import 'package:studyu_app/widgets/selectable_button.dart';
import 'package:studyu_core/core.dart';

class ChoiceQuestionWidget extends QuestionWidget {
  final ChoiceQuestion question;
  final Function(Answer) onDone;
  final String multiSelectionText;
  final Answer<List<String>>? initialAnswer;

  const ChoiceQuestionWidget({
    super.key,
    required this.question,
    required this.onDone,
    required this.multiSelectionText,
    this.initialAnswer,
  });

  @override
  State<ChoiceQuestionWidget> createState() => _ChoiceQuestionWidgetState();

  @override
  String? get subtitle => question.multiple ? multiSelectionText : null;
}

class _ChoiceQuestionWidgetState extends State<ChoiceQuestionWidget> {
  late List<Choice> selected;
  late bool confirmButtonTouched;

  @override
  void initState() {
    super.initState();
    final initialChoiceIds = widget.initialAnswer?.response ?? [];
    selected = widget.question.choices
        .where((choice) => initialChoiceIds.contains(choice.id))
        .toList();
    confirmButtonTouched = widget.initialAnswer != null;
  }

  void tapped(Choice choice) {
    setState(() {
      if (!widget.question.multiple) selected.clear();
      if (selected.contains(choice)) {
        selected.remove(choice);
      } else {
        selected.add(choice);
      }
    });

    // Auto-submit for single choice questions or multi-choice on subsequent answers
    if (!widget.question.multiple || confirmButtonTouched) {
      confirm();
    }
  }

  void confirm() {
    setState(() {
      confirmButtonTouched = true;
    });
    widget.onDone(widget.question.constructAnswer(selected));
  }

  @override
  Widget build(BuildContext context) {
    final choiceWidgets = widget.question.choices
        .map<Widget>(
          (choice) => SelectableButton(
            selected: selected.contains(choice),
            onTap: () => tapped(choice),
            child: Text(
              choice.text,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        )
        .toList();

    if (widget.question.multiple && !confirmButtonTouched) {
      choiceWidgets.add(
        OutlinedButton(
          onPressed: confirm,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
            foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          ),
          child: Text(AppLocalizations.of(context)!.confirm),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: choiceWidgets.length,
      itemBuilder: (context, index) => choiceWidgets[index],
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}
