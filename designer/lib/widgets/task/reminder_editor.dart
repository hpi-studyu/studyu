import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';

class ReminderEditor extends StatefulWidget {
  final StudyUTimeOfDay reminder;
  final void Function() remove;

  const ReminderEditor({@required this.reminder, @required this.remove, Key key}) : super(key: key);

  @override
  _ReminderEditorState createState() => _ReminderEditorState();
}

class _ReminderEditorState extends State<ReminderEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    final time = widget.reminder;
    return FormBuilder(
        key: _editFormKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // readonly: true,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MdiIcons.bell, color: Theme.of(context).colorScheme.secondary),
              SizedBox(width: 8),
              Expanded(
                child: FormBuilderDateTimePicker(
                  name: 'time',
                  inputType: InputType.time,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Reminder time',
                  ),
                  alwaysUse24HourFormat: true,
                  initialValue: DateTime(0, 0, 0, time.hour, time.minute),
                  onChanged: (value) {
                    saveFormChanges();
                  },
                ),
              ),
              SizedBox(width: 8),
              TextButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: widget.remove,
                label: Text(AppLocalizations.of(context).delete, style: TextStyle(color: Colors.red)),
              ),
              Spacer(flex: 4),
            ],
          )
        ]));
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      final time = _editFormKey.currentState.value['time'] as DateTime;
      if (time == null) return;
      setState(() {
        widget.reminder.hour = time.hour;
        widget.reminder.minute = time.minute;
      });
    }
  }
}
