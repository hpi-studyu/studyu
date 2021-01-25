import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyu_designer/designer/help_wrapper.dart';
import 'package:studyu_designer/models/app_state.dart';

import '../widgets/task/task_editor.dart';
import '../widgets/util/designer_add_button.dart';

class ObservationDesigner extends StatefulWidget {
  @override
  _ObservationDesignerState createState() => _ObservationDesignerState();
}

class _ObservationDesignerState extends State<ObservationDesigner> {
  List<Observation> _observations;

  void _addObservation() {
    setState(() {
      _observations.add(QuestionnaireTask.designerDefault());
    });
  }

  void _removeObservation(Observation observation) {
    setState(() {
      _observations.remove(observation);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().draftStudy == null) return Container();
    _observations = context.watch<AppState>().draftStudy.studyDetails.observations;
    return DesignerHelpWrapper(
      helpTitle: AppLocalizations.of(context).observations_help_title,
      helpText: AppLocalizations.of(context).observations_help_body,
      studyPublished: context.watch<AppState>().draftStudy.published,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    for (final observation in _observations)
                      TaskEditor(
                        key: ValueKey(observation.id),
                        task: observation,
                        remove: () => _removeObservation(observation),
                      ),
                    SizedBox(height: 200)
                  ],
                ),
              ),
            ),
          ),
          DesignerAddButton(label: Text(AppLocalizations.of(context).add_observation), add: _addObservation)
        ],
      ),
    );
  }
}
