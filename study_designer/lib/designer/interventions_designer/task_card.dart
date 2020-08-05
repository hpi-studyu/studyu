import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/models/designer_state.dart';
import 'package:studyou_core/models/models.dart';

class TaskCard extends StatefulWidget {
  final int interventionIndex;
  final int taskIndex;
  final bool isEditing;
  final void Function(int taskIndex) remove;
  final void Function(int interventionIndex) onTap;

  const TaskCard(
      {@required this.interventionIndex,
      @required this.taskIndex,
      @required this.remove,
      @required this.isEditing,
      @required this.onTap,
      Key key})
      : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Task task;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    task = context
        .watch<DesignerModel>()
        .draftStudy
        .studyDetails
        .interventionSet
        .interventions[widget.interventionIndex]
        .tasks[widget.taskIndex];

    final cardContent = <Widget>[];
    cardContent.add(Text('Task ${(widget.taskIndex + 1).toString()}'));
    if (widget.isEditing) {
      cardContent.add(_buildDeleteButton());
      cardContent.add(_buildEditMetaDataForm());
    } else {
      cardContent.add(_buildShowMetaData());
    }

    return GestureDetector(
        onTap: () {
          widget.onTap(widget.taskIndex);
        },
        child: Container(
            margin: EdgeInsets.all(10.0),
            decoration: BoxDecoration(border: Border.all()),
            child: Column(children: cardContent)));
  }

  Widget _buildDeleteButton() {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            widget.remove(widget.taskIndex);
          },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Widget _buildEditMetaDataForm() {
    return FormBuilder(
      key: _editFormKey,
      autovalidate: true,
      // readonly: true,
      child: Column(
        children: <Widget>[
          FormBuilderTextField(
              onChanged: (value) {
                saveFormChanges();
              },
              attribute: 'title',
              maxLength: 40,
              decoration: InputDecoration(labelText: 'Title'),
              initialValue: task.title),
//          FormBuilderTextField(
//              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
//              keyboardType: TextInputType.number,
//              onChanged: (value) {
//                saveFormChanges();
//              },
//              attribute: 'hour',
//              decoration: InputDecoration(labelText: 'Hour'),
//              initialValue: task.hour.toString()),
//          FormBuilderTextField(
//              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
//              keyboardType: TextInputType.number,
//              onChanged: (value) {
//                saveFormChanges();
//              },
//              attribute: 'minute',
//              decoration: InputDecoration(labelText: 'Minute'),
//              initialValue: task.minute.toString()),
        ],
      ),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
//        task.title = _editFormKey.currentState.value['title'];
//        task.hour = int.parse(_editFormKey.currentState.value['hour']);
//        task.minute = int.parse(_editFormKey.currentState.value['minute']);
      });
    }
  }

  Widget _buildShowMetaData() {
    return Column(
      children: [
        ListTile(title: Text(task.title.isEmpty ? 'Name' : task.title)),
//        Text('${task.hour}:${task.minute}')
      ],
    );
  }
}
