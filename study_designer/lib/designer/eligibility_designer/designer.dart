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

  @override
  void initState() {
    super.initState();
    _selectedIndex = null;
  }

  void _addItem() {
    setState(() {
      final newItem = LocalQuestion()..question = '';
      _list.add(newItem);
    });
  }

  void _removeItem(index) {
    setState(() {
      _list.removeAt(index);
      _selectedIndex = null;
    });
  }

  void _selectItem(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _list = context.watch<DesignerModel>().draftStudy.studyDetails.eligibilityQuestionnaire;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = null),
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
                        isEditing: entry.key == _selectedIndex,
                        onTap: _selectItem,
                        remove: _removeItem,
                      ))
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
