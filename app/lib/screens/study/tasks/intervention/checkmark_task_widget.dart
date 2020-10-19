import 'package:flutter/material.dart';
import 'package:pimp_my_button/pimp_my_button.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/interventions/tasks/checkmark_task.dart';
import 'package:studyou_core/models/models.dart';
import 'package:studyou_core/models/results/result.dart';
import 'package:studyou_core/queries/queries.dart';
import 'package:studyou_core/util/localization.dart';

import '../../../../models/app_state.dart';

class CheckmarkTaskWidget extends StatelessWidget {
  final CheckmarkTask task;

  const CheckmarkTaskWidget({this.task, Key key}) : super(key: key);

  Future<void> _handleCompletion(BuildContext context, Future<void> animation) async {
    final model = context.read<AppState>();
    final activeStudy = model.activeStudy;
    final result = Result<bool>()
      ..result = true
      ..timeStamp = DateTime.now()
      ..taskId = task.id;
    activeStudy.addResult(result);
    if (await StudyQueries.saveUserStudy(activeStudy) != null) {
      await animation;
      Navigator.pop(context, true);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(Nof1Localizations.of(context).translate('could_not_save_results')),
        duration: Duration(seconds: 10),
        action: SnackBarAction(label: 'retry', onPressed: () => _handleCompletion(context, animation)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PimpedButton(
        particle: DemoParticle(),
        pimpedWidgetBuilder: (context, controller) => RaisedButton.icon(
            onPressed: () => _handleCompletion(context, controller.forward(from: 0)),
            icon: Icon(Icons.check, size: 32),
            label: Text(Nof1Localizations.of(context).translate('completed'), style: TextStyle(fontSize: 24))));
  }
}
