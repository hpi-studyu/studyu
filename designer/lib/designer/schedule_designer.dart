import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/designer/help_wrapper.dart';
import 'package:studyu_designer/models/app_state.dart';

class ScheduleDesigner extends StatefulWidget {
  @override
  _ScheduleDesignerState createState() => _ScheduleDesignerState();
}

class _ScheduleDesignerState extends State<ScheduleDesigner> {
  Study _draftStudy;
  final GlobalKey<FormBuilderState> _editFormKey = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
    _draftStudy = context.read<AppState>().draftStudy;
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().draftStudy == null) return Container();
    return DesignerHelpWrapper(
      helpTitle: AppLocalizations.of(context).schedule_help_title,
      helpText: AppLocalizations.of(context).schedule_help_body,
      studyPublished: _draftStudy.published,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _editFormKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: <Widget>[
                FormBuilderTextField(
                  onChanged: _saveFormChanges,
                  name: 'numberOfCycles',
                  decoration: InputDecoration(labelText: AppLocalizations.of(context).number_of_cycles),
                  initialValue: _draftStudy.schedule.numberOfCycles.toString(),
                ),
                FormBuilderTextField(
                  onChanged: _saveFormChanges,
                  name: 'phaseDuration',
                  decoration: InputDecoration(labelText: AppLocalizations.of(context).phase_duration),
                  initialValue: _draftStudy.schedule.phaseDuration.toString(),
                ),
                FormBuilderSwitch(
                  onChanged: _saveFormChanges,
                  title: Text(AppLocalizations.of(context).include_baseline),
                  name: 'includeBaseline',
                  initialValue: _draftStudy.schedule.includeBaseline,
                ),
                FormBuilderDropdown(
                  onChanged: _saveFormChanges,
                  name: 'sequence',
                  decoration: InputDecoration(labelText: AppLocalizations.of(context).schedule),
                  initialValue: _draftStudy.schedule.sequence,
                  items: PhaseSequence.values
                      .map(
                        (sequence) => DropdownMenuItem(
                          value: sequence,
                          child: Text(
                            '${sequence.toString().substring(sequence.toString().indexOf('.') + 1)} (${_draftStudy.schedule.nameOfSequence})',
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveFormChanges(value) {
    _editFormKey.currentState.save();
    if (_editFormKey.currentState.validate()) {
      setState(() {
        _draftStudy.schedule
          ..numberOfCycles = int.parse(_editFormKey.currentState.value['numberOfCycles'] as String)
          ..phaseDuration = int.parse(_editFormKey.currentState.value['phaseDuration'] as String)
          ..includeBaseline = _editFormKey.currentState.value['includeBaseline'] as bool
          ..sequence = _editFormKey.currentState.value['sequence'] as PhaseSequence
          ..sequenceCustom = _editFormKey.currentState.value['sequenceCustom'] as String;
      });
    }
  }
}
