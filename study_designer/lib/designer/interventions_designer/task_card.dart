import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final void Function() remove;

  const TaskCard({@required this.task, @required this.remove, Key key}) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final cardContent = <Widget>[];
    cardContent.add(Text('Task'));

    cardContent.add(_buildDeleteButton());
    cardContent.add(_buildEditMetaDataForm());

    return Container(
        margin: EdgeInsets.all(10.0),
        decoration: BoxDecoration(border: Border.all()),
        child: Column(children: cardContent));
  }

  Widget _buildDeleteButton() {
    return ButtonBar(
      children: <Widget>[
        FlatButton(
          onPressed: () {
            widget.remove();
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
              initialValue: widget.task.title),
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
}
