import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/designer/eligibility_designer/question_card.dart';

import '../../models/designer_state.dart';

class EligibilityDesigner extends StatefulWidget {
  @override
  _EligibilityDesignerState createState() => _EligibilityDesignerState();
}

class _EligibilityDesignerState extends State<EligibilityDesigner> {
  List<LocalQuestion> _list;
  int _selectedIndex;
  bool _validated;

  @override
  void initState() {
    super.initState();
    _selectedIndex = null;
    _validated = true;
  }

  void _addItem() {
    if (_validated) {
      setState(() {
        _validated = false;
        final newItem = LocalQuestion()..question = '';
        _list.add(newItem);
        _selectedIndex = _list.length - 1;
      });
    }
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
    _list = context.watch<DesignerModel>().draftStudy.studyDetails.eligibilityQuestionnaire;
    final theme = Theme.of(context);
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
                  .map((entry) => QuestionCard(
                      index: entry.key,
                      item: context.watch<DesignerModel>().draftStudy.studyDetails.eligibilityQuestionnaire[entry.key],
                      isEditing: entry.key == _selectedIndex,
                      onTap: _selectItem,
                      remove: _removeItem,
                      setValidated: _setValidated))
                  .toList(),
              RaisedButton.icon(
                  textTheme: ButtonTextTheme.primary,
                  onPressed: _addItem,
                  icon: Icon(Icons.add),
                  color: Colors.green,
                  label: Text('Add Question')),
            ],
          ),
        ),
      ),
    );
  }
}
