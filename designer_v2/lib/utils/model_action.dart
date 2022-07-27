import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class ModelAction<T> {
  final T type;
  final String label;
  IconData? icon;
  final Function onExecute;
  final bool isAvailable;
  final bool isDestructive;

  ModelAction({
    required this.type,
    required this.label,
    required this.onExecute,
    this.isAvailable = true,
    this.isDestructive = false,
    this.icon
  });
}

abstract class IModelActionProvider<T,V> {
  List<ModelAction<T>> availableActions(V model);
}

abstract class IListActionProvider<T,V> extends IModelActionProvider<T,V> {
  void onSelectItem(V item);
  void onNewItem();
}

enum ModelActionType {
  edit,
  delete,
  clipboard
}

/// Provides a human-readable translation of the model action type
extension ModelActionTypeFormatted on ModelActionType {
  String get string {
    switch (this) {
      case ModelActionType.edit:
        return "Edit".hardcoded;
      case ModelActionType.delete:
        return "Delete".hardcoded;
      case ModelActionType.clipboard:
        return "Copy to clipboard".hardcoded;
      default:
        return "[Invalid ModelActionType]";
    }
  }
}

Map<ModelActionType, IconData> modelActionIcons = {
  ModelActionType.edit: Icons.edit_rounded,
  ModelActionType.delete: Icons.delete_rounded,
  ModelActionType.clipboard: Icons.copy_rounded,
};

/// Decorates a list of [actions] with their corresponding icon
/// Helps us keep presentational data & business logic separate
List<ModelAction<T>> withIcons<T>(
    List<ModelAction<T>> actions,
    Map<T,IconData> iconMap) {
  for (final action in actions) {
    if (iconMap.containsKey(action.type)) {
      action.icon = iconMap[action.type];
    }
  }
  return actions;
}
