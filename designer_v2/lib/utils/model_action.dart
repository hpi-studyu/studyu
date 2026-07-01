import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/confirmation_dialog.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

typedef ModelActionHandler = FutureOr<void> Function();
typedef ModelActionConfirmationDialogBuilder =
    Widget Function(BuildContext dialogContext, ModelAction action);

class ModelActionConfirmation {
  const ModelActionConfirmation({
    required this.title,
    this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.icon,
    this.customContent,
    this.dialogBuilder,
  });

  final String title;
  final String? message;
  final String? confirmLabel;
  final String? cancelLabel;
  final IconData? icon;
  final Widget? customContent;
  final ModelActionConfirmationDialogBuilder? dialogBuilder;
}

class ModelActionConfirmations {
  static ModelActionConfirmation delete({
    required String subject,
    String? title,
    String? message,
    IconData? icon,
  }) {
    return ModelActionConfirmation(
      title: title ?? tr.dialog_delete_title(subject),
      message: message ?? tr.dialog_delete_description(subject),
      icon: icon,
    );
  }

  static ModelActionConfirmation remove({
    required String subject,
    String? title,
    String? message,
    IconData? icon,
  }) {
    return ModelActionConfirmation(
      title: title ?? tr.dialog_remove_title(subject),
      message: message ?? tr.dialog_remove_description(subject),
      icon: icon,
    );
  }
}

class ModelAction<T> {
  final T type;
  final String label;
  IconData? icon;
  final String? tooltip;
  final ModelActionHandler onExecute;
  final ModelActionConfirmation? confirmation;
  final bool isHeader;
  final bool isSeparator;
  final bool isAvailable;
  final bool isDestructive;
  final bool isChecked;
  final bool showBadge;

  ModelAction({
    required this.type,
    required this.label,
    required this.onExecute,
    this.confirmation,
    this.isSeparator = false,
    this.isHeader = false, // Added default
    this.isAvailable = true,
    this.isDestructive = false,
    this.icon,
    this.tooltip,
    this.isChecked = false,
    this.showBadge = false,
  });

  static ModelAction addSeparator() {
    return ModelAction(
      type: null,
      label: '',
      onExecute: () {},
      isSeparator: true,
    );
  }

  static ModelAction addHeader(String label) {
    return ModelAction(
      type: null,
      label: label,
      onExecute: () {},
      isHeader: true,
    );
  }

  Future<void> execute(BuildContext context) async {
    if (confirmation != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) {
          final dialogBuilder = confirmation!.dialogBuilder;
          if (dialogBuilder != null) {
            return dialogBuilder(dialogContext, this);
          }

          return StandardConfirmationDialog(
            title: confirmation!.title,
            message: confirmation!.message,
            customContent: confirmation!.customContent,
            icon: confirmation!.icon,
            actions: [
              ConfirmationDialogAction(
                label: confirmation!.cancelLabel ?? tr.dialog_cancel,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
              ConfirmationDialogAction(
                label: confirmation!.confirmLabel ?? label,
                isDestructive: isDestructive,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ],
          );
        },
      );
      if (confirmed != true) {
        return;
      }
    }

    await Future.sync(onExecute);
  }
}

abstract class IModelActionProvider<V> {
  List<ModelAction> availableActions(V model);
}

abstract class IListActionProvider<V> extends IModelActionProvider<V> {
  void onSelectItem(V item);
  void onNewItem();
}

enum ModelActionType {
  edit,
  delete,
  remove, // same semantics as delete
  duplicate,
  clipboard,
  primary, // ReportSection
}

/// Provides a human-readable translation of the model action type
extension ModelActionTypeFormatted on ModelActionType {
  String get string {
    switch (this) {
      case ModelActionType.edit:
        return tr.action_edit;
      case ModelActionType.delete:
        return tr.action_delete;
      case ModelActionType.remove:
        return tr.action_remove;
      case ModelActionType.duplicate:
        return tr.action_duplicate;
      case ModelActionType.clipboard:
        return tr.action_clipboard;
      case ModelActionType.primary:
        return tr.action_reportPrimary;
    }
  }
}

Map<ModelActionType, IconData> modelActionIcons = {
  ModelActionType.edit: Icons.edit_rounded,
  ModelActionType.delete: Icons.delete_rounded,
  ModelActionType.remove: Icons.close_rounded,
  ModelActionType.duplicate: Icons.file_copy_rounded,
  ModelActionType.clipboard: Icons.copy_rounded,
  ModelActionType.primary: Icons.arrow_circle_up_rounded,
};

/// Decorates a list of [actions] with their corresponding icon
/// Helps us keep presentational data & business logic separate
List<ModelAction<T>> withIcons<T>(
  List<ModelAction<T>> actions,
  Map<T, IconData> iconMap,
) {
  for (final action in actions) {
    if (iconMap.containsKey(action.type)) {
      action.icon = iconMap[action.type];
    }
  }
  return actions;
}
