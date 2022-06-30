import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';
import 'package:provider/provider.dart';
import 'package:studyu_designer_v2/features/legacy/designer/app_state.dart';
import '../buttons.dart';

class ReminderEditor extends StatefulWidget {
  final StudyUTimeOfDay reminder;
  final void Function() remove;

  const ReminderEditor({required this.reminder, required this.remove, Key? key}) : super(key: key);

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(MdiIcons.bell, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: FormBuilderDateTimePicker(
                  name: 'time',
                  inputType: InputType.time,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Reminder time',
                  ),
                  alwaysUse24HourFormat: true,
                  initialValue: DateTime(0, 0, 0, time.hour, time.minute),
                  onChanged: (value) {
                    saveFormChanges();
                  },
                ),
              ),
              const SizedBox(width: 8),
              DeleteButton(onPressed: widget.remove),
              const Spacer(flex: 4),
            ],
          )
        ],
      ),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState!.save();
    if (_editFormKey.currentState!.validate()) {
      final time = _editFormKey.currentState!.value['time'] as DateTime;
      if (time == null) return;
      setState(() {
        widget.reminder.hour = time.hour;
        widget.reminder.minute = time.minute;
      });
      context.read<AppState>().updateDelegate();
    }
  }
}
