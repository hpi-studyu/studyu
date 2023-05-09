import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  Future<void> _handleCompletion(BuildContext context) async {
    final state = context.read<AppState>();
    final activeStudy = state.activeSubject;
    try {
      if (state.trackParticipantProgress) {
        await activeStudy.addResult<bool>(taskId: widget.task.id, periodId: widget.completionPeriod.id, result: true);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on PostgrestException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).could_not_save_results),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(label: 'retry', onPressed: () => _handleCompletion(context)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.green)),
      onPressed: () => _handleCompletion(context),
      icon: const Icon(Icons.check),
      label: Text(AppLocalizations.of(context).complete),
    );
  }
}
