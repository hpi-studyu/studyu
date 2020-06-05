import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../database/models/questionnaire/answers/multiple_choice_answer.dart';
import '../database/models/questionnaire/questions/multiple_choice_question.dart';

class MultipleChoiceQuestionWidget extends StatefulWidget {
  final MultipleChoiceQuestion question;
  final Function(MultipleChoiceAnswer) onDone;

  MultipleChoiceQuestionWidget({Key key, @required this.question, this.onDone});

  @override
  State<MultipleChoiceQuestionWidget> createState() => _MultipleChoiceQuestionWidgetState();
}

class _MultipleChoiceQuestionWidgetState extends State<MultipleChoiceQuestionWidget> {
  List<Choice> selected = [];
  int maxSelection;
  String subtitle = '';
  final List<Widget> _questionFooter = [];
  final ValueNotifier<MultipleChoiceAnswer> _currentAnswerNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    maxSelection = widget.question.multiple ? widget.question.choices.length : 1;
    //TODO translate
    subtitle = 'Select ${widget.question.multiple ? 'at least ' : ''}1';
    if (maxSelection > 1) {
      _questionFooter.addAll([
        SizedBox(
          height: 5,
        ),
        ValueListenableBuilder(
          valueListenable: _currentAnswerNotifier,
          builder: (_, _answer, __) => RaisedButton(
            onPressed: _answer != null ? () => widget.onDone(_answer) : null,
            //TODO translate
            child: Text('Next'),
          ),
        ),
      ]);
    }
  }

  void tapped(Choice choice) {
    setState(() {
      if (!selected.map((ch) => ch.id).contains(choice.id)) {
        selected.add(choice);
        if (selected.length > maxSelection) selected.removeAt(0);
      } else {
        selected.removeWhere((ch) => ch.id == choice.id);
      }
      var answer;
      if (selected.isNotEmpty) {
        answer = MultipleChoiceAnswer(
          widget.question.id,
          DateTime.now(),
          widget.question.id,
          selected.toSet(),
        );
      }
      _currentAnswerNotifier.value = answer;
    });
    if (maxSelection == 1 && _currentAnswerNotifier.value != null) {
      widget.onDone(_currentAnswerNotifier.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final choiceWidgets = widget.question.choices
        .map<Widget>((choice) => Card(
              child: InkWell(
                onTap: () => tapped(choice),
                child: ListTile(
                  title: Text(choice.value),
                  trailing: Visibility(
                    visible: selected.map((ch) => ch.id).contains(choice.id),
                    child: Icon(MdiIcons.checkboxMarked),
                  ),
                ),
              ),
            ))
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          subtitle,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        SizedBox(
          height: 10,
        ),
        ...choiceWidgets,
        ..._questionFooter,
      ],
    );
  }
}
