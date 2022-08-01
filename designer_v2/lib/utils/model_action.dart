import 'package:flutter/widgets.dart';

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

abstract class IModelActionProvider<T> {
  List<ModelAction<T>> availableActions();
}
