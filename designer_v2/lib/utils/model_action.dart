class ModelAction<T> {
  final T type;
  final String label;
  final Function onExecute;
  final bool isAvailable;
  final bool isDestructive;

  const ModelAction({
    required this.type,
    required this.label,
    required this.onExecute,
    this.isAvailable = true,
    this.isDestructive = false
  });
}

abstract class IModelActionProvider<T> {
  List<ModelAction<T>> availableActions();
}
