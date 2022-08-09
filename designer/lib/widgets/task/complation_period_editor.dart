import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:studyu_core/core.dart';

import '../buttons.dart';

class CompletionPeriodEditor extends StatefulWidget {
  final CompletionPeriod completionPeriod;
  final bool isFirst;
  final void Function() remove;

  const CompletionPeriodEditor({
    @required this.completionPeriod,
    @required this.isFirst,
    @required this.remove,
    Key key,
  }) : super(key: key);

  @override
  _CompletionPeriodEditorState createState() => _CompletionPeriodEditorState();
}

class _CompletionPeriodEditorState extends State<CompletionPeriodEditor> {
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: _editFormKey,
      autovalidateMode: AutovalidateMode.always,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: [
              Icon(Icons.timelapse, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Expanded(
                child: FormBuilderDateTimePicker(
                  initialValue: DateTime(
                    0,
                    0,
                    0,
                    widget.completionPeriod.unlockTime.hour,
                    widget.completionPeriod.unlockTime.minute,
                  ),
                  name: 'unlock',
                  inputType: InputType.time,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Unlock time',
                  ),
                  onChanged: (value) => saveFormChanges(),
                ),
              ),
              const SizedBox(width: 8),
              const Text('to'),
              const SizedBox(width: 8),
              Expanded(
                child: FormBuilderDateTimePicker(
                  initialValue:
                      DateTime(0, 0, 0, widget.completionPeriod.lockTime.hour, widget.completionPeriod.lockTime.minute),
                  name: 'lock',
                  validator: (lockTime) {
                    final unlockTime = _editFormKey.currentState.value['unlock'] as DateTime;
                    if (lockTime.isBefore(unlockTime)) return 'Is before unlock time';
                    return null;
                  },
                  inputType: InputType.time,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    labelText: 'Lock time',
                  ),
                  onChanged: (value) => saveFormChanges(),
                ),
              ),
              if (!widget.isFirst) DeleteButton(onPressed: widget.remove),
              Spacer(flex: widget.isFirst ? 4 : 3),
            ],
          ),
        ],
      ),
    );
  }

  void saveFormChanges() {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      final unlockTime = _editFormKey.currentState.value['unlock'] as DateTime;
      final lockTime = _editFormKey.currentState.value['lock'] as DateTime;
      setState(() {
        if (unlockTime != null) {
          widget.completionPeriod.unlockTime.hour = unlockTime.hour;
          widget.completionPeriod.unlockTime.minute = unlockTime.minute;
        }
        if (lockTime != null) {
          widget.completionPeriod.lockTime.hour = lockTime.hour;
          widget.completionPeriod.lockTime.minute = lockTime.minute;
        }
      });
    }
  }
}
