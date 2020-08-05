import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/widgets/question_card.dart';
import 'package:study_designer/widgets/question_edit_widget.dart';
import 'package:study_designer/widgets/question_show_widget.dart';
import 'package:study_designer/widgets/study_designer_card.dart';
import 'package:studyou_core/models/models.dart';
import 'package:uuid/uuid.dart';

import '../../models/designer_state.dart';

class EligibilityDesigner extends StatefulWidget {
  @override
  _EligibilityDesignerState createState() => _EligibilityDesignerState();
}

class _EligibilityDesignerState extends State<EligibilityDesigner> {
  List<Question> _list;
  int _selectedIndex;
  bool _validated;

  @override
  void initState() {
    super.initState();
    _selectedIndex = null;
    _validated = true;
  }

  void _addItem(item) {
    if (_validated) {
      setState(() {
        _validated = true;
        _list.add(item);
        _selectedIndex = _list.length - 1;
      });
    }
  }

  void _addBooleanQuestion() {
    final question = BooleanQuestion()..id = Uuid().v4();
    _addItem(question);
  }

  void _removeItem(index) {
    setState(() {
      _validated = true;
      _list.removeAt(index);
      _selectedIndex = null;
    });
  }

  void _selectItem(index) {
    if (_validated) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _setValidated(boolean) {
    setState(() {
      _validated = boolean;
    });
  }

  @override
  Widget build(BuildContext context) {
    _list = context.watch<DesignerModel>().draftStudy.studyDetails.questionnaire.questions;
    return GestureDetector(
      onTap: () => setState(() => _selectItem(null)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              ..._list
                  .asMap()
                  .entries
                  .map((entry) => StudyDesignerCard(
                      index: entry.key,
                      onTap: _selectItem,
                      remove: _removeItem,
                      isEditing: entry.key == _selectedIndex,
                      child: entry.key == _selectedIndex? QuestionEditWidget(question: entry.value) : QuestionShowWidget(question: entry.value)
                      ))
                  .toList(),
              RaisedButton.icon(
                  textTheme: ButtonTextTheme.primary,
                  onPressed: _addBooleanQuestion,
                  icon: Icon(Icons.add),
                  color: Colors.green,
                  label: Text('Add Boolean Question'))
            ],
          ),
        ),
      ),
    );
  }
}
