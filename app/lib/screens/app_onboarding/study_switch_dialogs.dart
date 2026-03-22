import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/util/fitbit_handler.dart';
import 'package:studyu_app/util/schedule_notifications.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class StudySwitchDialogs {
  // Returns true if the switch was successfully confirmed and executed
  static Future<bool> confirmSwitchToDeepLinkedStudy(
    BuildContext context,
    Study targetStudy,
    StudySubject currentSubject,
  ) async {
    final loc = AppLocalizations.of(context)!;
    final stayInCurrentStudy =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(loc.deep_link_switch_warning_title),
              content: Text(
                loc.deep_link_switch_warning_description(
                  currentSubject.study.title ?? '',
                  targetStudy.title ?? '',
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => context.pop(true),
                  child: Text(loc.deep_link_switch_primary_return),
                ),
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(loc.deep_link_switch_secondary_continue),
                ),
              ],
            );
          },
        ) ??
        true;

    if (stayInCurrentStudy) {
      return false;
    }

    if (!context.mounted) return false;

    final selectedDeleteMode =
        await showDialog<String>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(loc.deep_link_switch_data_choice_title),
              content: Text(
                '${loc.deep_link_switch_data_choice_description}\n\n'
                '${loc.soft_delete_desc}${currentSubject.study.title}${loc.soft_delete_desc_2}\n\n'
                '${loc.hard_delete_desc}',
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop('cancel'),
                  child: Text(loc.cancel),
                ),
                FilledButton(
                  onPressed: () => context.pop('soft'),
                  child: Text(loc.deep_link_switch_soft_delete_button),
                ),
                FilledButton(
                  onPressed: () => context.pop('hard'),
                  child: Text(loc.deep_link_switch_hard_delete_button),
                ),
              ],
            );
          },
        ) ??
        'cancel';

    if (selectedDeleteMode == 'cancel') {
      return false;
    }

    if (!context.mounted) return false;

    if (selectedDeleteMode == 'soft') {
      return await _runFinalSoftDeleteConfirmation(
        context,
        loc,
        currentSubject,
      );
    } else {
      return await _runFinalHardDeleteConfirmation(
        context,
        loc,
        currentSubject,
      );
    }
  }

  static Future<bool> _runFinalSoftDeleteConfirmation(
    BuildContext context,
    AppLocalizations loc,
    StudySubject currentSubject,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(loc.deep_link_switch_confirm_soft_title),
              content: Text(
                '${loc.soft_delete_desc}${currentSubject.study.title}${loc.soft_delete_desc_2}',
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(loc.cancel),
                ),
                FilledButton(
                  onPressed: () => context.pop(true),
                  child: Text(loc.deep_link_switch_confirm_soft_button),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return false;
    }

    await currentSubject.softDelete();
    await deleteActiveStudyReference();
    await FitbitHandler.deleteFitbitCredentials(currentSubject.studyId);
    if (context.mounted) {
      await cancelNotifications(context);
    }
    return true;
  }

  static Future<bool> _runFinalHardDeleteConfirmation(
    BuildContext context,
    AppLocalizations loc,
    StudySubject currentSubject,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(loc.deep_link_switch_confirm_hard_title),
              content: Text(loc.deep_link_switch_confirm_hard_description),
              actions: [
                TextButton(
                  onPressed: () => context.pop(false),
                  child: Text(loc.cancel),
                ),
                FilledButton(
                  onPressed: () => context.pop(true),
                  child: Text(loc.deep_link_switch_confirm_hard_button),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) {
      return false;
    }

    await currentSubject.delete();
    await deleteLocalData();
    await FitbitHandler.deleteFitbitCredentials(currentSubject.studyId);
    if (context.mounted) {
      await cancelNotifications(context);
    }
    return true;
  }
}
