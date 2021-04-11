import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:studyou_core/core.dart';

class FixedScheduleEditor extends StatefulWidget {
  final FixedSchedule schedule;
  final void Function() remove;

  const FixedScheduleEditor({@required this.schedule, @required this.remove, Key key}) : super(key: key);

  @override
  _FixedScheduleEditorState createState() => _FixedScheduleEditorState();
}

class _FixedScheduleEditorState extends State<FixedScheduleEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
        key: _editFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).hour),
                    initialValue: widget.schedule.time.hour.toString()),
              ),
              Expanded(
                child: FormBuilderTextField(
                    onChanged: (value) {
                      saveFormChanges();
                    },
                    name: 'minute',
                    decoration: InputDecoration(labelText: AppLocalizations.of(context).minute),
                    initialValue: widget.schedule.time.minute.toString()),
              ),
              Expanded(
                child: TextButton(
                  onPressed: widget.remove,
                  child: Text(AppLocalizations.of(context).delete),
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
        widget.schedule.time.hour = int.parse(_editFormKey.currentState.value['hour'] as String);
        widget.schedule.time.minute = int.parse(_editFormKey.currentState.value['minute'] as String);
      });
    }
  }
}
