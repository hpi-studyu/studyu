import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:study_designer/models/designer_state.dart';

class ScheduleCard extends StatefulWidget {
  final int interventionIndex;
  final int taskIndex;
  final int scheduleIndex;
  final bool isEditing;
  final void Function(int taskIndex) remove;
  final void Function(int interventionIndex) onTap;

  const ScheduleCard(
      {@required this.interventionIndex,
      @required this.taskIndex,
      @required this.scheduleIndex,
      @required this.remove,
      @required this.isEditing,
      @required this.onTap,
      Key key})
      : super(key: key);

  @override
  _ScheduleCardState createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  LocalFixedSchedule schedule;

  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    schedule = context
        .watch<DesignerModel>()
        .draftStudy
        .studyDetails
        .interventions[widget.interventionIndex]
        .tasks[widget.taskIndex]
        .schedules[widget.scheduleIndex];

    final cardContent = <Widget>[];
    cardContent.add(Text('Schedule ${(widget.scheduleIndex + 1).toString()}'));
    if (widget.isEditing) {
      cardContent.add(_buildDeleteButton());
      cardContent.add(_buildEditMetaDataForm());
    } else {
      cardContent.add(_buildShowMetaData());
    }

    return GestureDetector(
        onTap: () {
          widget.onTap(widget.scheduleIndex);
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
            widget.remove(widget.scheduleIndex);
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
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              onChanged: (value) {
                saveFormChanges();
              },
              attribute: 'hour',
              maxLength: 40,
              decoration: InputDecoration(labelText: 'Hour'),
              initialValue: schedule.hour.toString()),
          FormBuilderTextField(
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.number,
              onChanged: (value) {
                saveFormChanges();
              },
              attribute: 'minute',
              decoration: InputDecoration(labelText: 'Minute'),
              initialValue: schedule.minute.toString()),
        ],
      ),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        schedule.hour = int.parse(_editFormKey.currentState.value['hour']);
        schedule.minute = int.parse(_editFormKey.currentState.value['minute']);
      });
    }
  }

  Widget _buildShowMetaData() {
    return Text('${schedule.hour}:${schedule.minute}');
  }
}
