import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyou_core/models/models.dart';

class FixedScheduleWidget extends StatefulWidget {
  final FixedSchedule schedule;
  final void Function() remove;

  const FixedScheduleWidget({@required this.schedule, @required this.remove, Key key}) : super(key: key);

  @override
  _FixedScheduleWidgetState createState() => _FixedScheduleWidgetState();
}

class _FixedScheduleWidgetState extends State<FixedScheduleWidget> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: _editFormKey,
        autovalidate: true,
        // readonly: true,
        child: Column(children: <Widget>[
          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                    onChanged: (value) {
                      saveFormChanges();
                    },
                    name: 'hour',
                    decoration: InputDecoration(labelText: 'Hour'),
                    initialValue: widget.schedule.time.hour.toString()),
              ),
              Expanded(
                child: FormBuilderTextField(
                    onChanged: (value) {
                      saveFormChanges();
                    },
                    name: 'minute',
                    decoration: InputDecoration(labelText: 'Minute'),
                    initialValue: widget.schedule.time.minute.toString()),
              ),
              Expanded(
                child: FlatButton(
                  onPressed: widget.remove,
                  child: const Text('Delete'),
                ),
              )
            ],
          )
        ]));
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        widget.schedule.time.hour = int.parse(_editFormKey.currentState.value['hour']);
        widget.schedule.time.minute = int.parse(_editFormKey.currentState.value['minute']);
      });
    }
  }
}
