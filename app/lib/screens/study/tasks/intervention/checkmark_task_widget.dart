import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pimp_my_button/pimp_my_button.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';

import '../../../../models/app_state.dart';

class CheckmarkTaskWidget extends StatefulWidget {
  final CheckmarkTask task;
  final CompletionPeriod completionPeriod;

  const CheckmarkTaskWidget({this.task, this.completionPeriod, Key key}) : super(key: key);

  @override
  State<CheckmarkTaskWidget> createState() => _CheckmarkTaskWidgetState();
}

class _CheckmarkTaskWidgetState extends State<CheckmarkTaskWidget> {
  Future<void> _handleCompletion(BuildContext context, Future<void> animation) async {
    final model = context.read<AppState>();
    final activeStudy = model.activeSubject;
    try {
      await activeStudy.addResult<bool>(taskId: widget.task.id, periodId: widget.completionPeriod.id, result: true);
      await animation;
      if (!mounted) return;
      Navigator.pop(context, true);
    } on PostgrestError {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).could_not_save_results),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'retry', onPressed: () => _handleCompletion(context, animation)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PimpedButton(
      particle: DemoParticle(),
      pimpedWidgetBuilder: (context, controller) => ElevatedButton.icon(
        onPressed: () => _handleCompletion(context, controller.forward(from: 0)),
        icon: const Icon(Icons.check, size: 32),
        label: Text(AppLocalizations.of(context).completed, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
