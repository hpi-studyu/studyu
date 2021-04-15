import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pimp_my_button/pimp_my_button.dart';
import 'package:postgrest/postgrest.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/core.dart';

import '../../../../models/app_state.dart';

class CheckmarkTaskWidget extends StatelessWidget {
  final CheckmarkTask task;

  const CheckmarkTaskWidget({this.task, Key key}) : super(key: key);

  Future<void> _handleCompletion(BuildContext context, Future<void> animation) async {
    final model = context.read<AppState>();
    final activeStudy = model.activeStudy;
    try {
      await activeStudy.addResult<bool>(taskId: task.id, result: true);
      await animation;
      Navigator.pop(context, true);
    } on PostgrestError {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).could_not_save_results),
        duration: Duration(seconds: 10),
        action: SnackBarAction(label: 'retry', onPressed: () => _handleCompletion(context, animation)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PimpedButton(
        particle: DemoParticle(),
        pimpedWidgetBuilder: (context, controller) => ElevatedButton.icon(
            onPressed: () => _handleCompletion(context, controller.forward(from: 0)),
            icon: Icon(Icons.check, size: 32),
            label: Text(AppLocalizations.of(context).completed, style: TextStyle(fontSize: 24))));
  }
}
