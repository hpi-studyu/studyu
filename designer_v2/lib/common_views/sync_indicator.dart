import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class SyncIndicator<T> extends StatelessWidget {
  const SyncIndicator({
    required this.state,
    required this.isDirty,
    this.lastSynced,
    Key? key
  }) : super(key: key);

  final AsyncValue<T> state;
  final DateTime? lastSynced;
  final bool isDirty;

  @override
  Widget build(BuildContext context) {
    Widget dataWidget;

    if (!isDirty && lastSynced != null) {
      dataWidget = Tooltip(
        richMessage: TextSpan(
          text: 'All changes saved!'.hardcoded,
          style: const TextStyle(fontWeight: FontWeight.bold),
          children: [
            const TextSpan(text: '\n\n'),
            TextSpan(
              text: 'Last saved: ${lastSynced.toString()}'.hardcoded,
            ),
          ],
        ),
        child: const Icon(Icons.check_circle_outline_rounded),
      );
    } else if (!isDirty && lastSynced == null) {
      dataWidget = Tooltip(
        message: "No changes yet. Any changes will be saved automatically.".hardcoded,
        child: const Icon(Icons.check_circle_outline_rounded),
      );
    } else { // isDirty
      dataWidget = Tooltip(
        message: "There are unsaved changes".hardcoded,
        child: const Icon(Icons.sync_disabled_outlined),
      );
    }

    return state.when(
      data: (data) => (state.isRefreshing)
          ? Tooltip(
              message: "Saving changes...".hardcoded,
              child: const Icon(Icons.sync_rounded),
          ) : dataWidget,
      error: (error, stackTrace) => Tooltip(
        message: "Changes could not be saved".hardcoded,
        child: const Icon(Icons.sync_problem_outlined),
      ),
      loading: () => Container(), // hide on initial load
    );
  }
}
