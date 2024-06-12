import 'dart:async';

import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';

class ModelAction<T> {
  final T type;
  final String label;
  IconData? icon;
  final FutureOr<void> Function() onExecute;
  final bool isSeparator;
  final bool isAvailable;
  final bool isDestructive;

  ModelAction({
    required this.type,
    required this.label,
    required this.onExecute,
    this.isSeparator = false,
      this.isAvailable = true,
      this.isDestructive = false,
      this.icon,});

  static ModelAction addSeparator() {
    return ModelAction(
      type: null,
      label: '',
      onExecute: () {},
      isSeparator: true,
    );
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
      default:
        return "[Invalid ModelActionType]";
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
