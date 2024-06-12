import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

/// Extension that implements a set of standard actions for elements of a
/// [FormViewModelCollection]
extension FormViewModelCollectionActions<T extends ManagedFormViewModel<D>,
    D extends IFormData> on FormViewModelCollection<T, D> {
  // implements IListActionProvider<T>

  List<ModelAction> availableActions(
    T formViewModel, {
    VoidCallbackOn<T>? onEdit,
    VoidCallbackOn<T>? onDuplicate,
    VoidCallbackOn<T>? onDelete,
    bool isReadOnly = false,
  }) {
    final actions = [
      ModelAction(
        type: ModelActionType.edit,
        label: ModelActionType.edit.string,
        onExecute: (onEdit != null) ? () => onEdit(formViewModel) : () => {},
        isAvailable: !isReadOnly,
      ),
      ModelAction(
        type: ModelActionType.duplicate,
        label: ModelActionType.duplicate.string,
        onExecute: (onDuplicate != null)
            ? () => onDuplicate(formViewModel)
            : () {
                final duplicateFormViewModel =
                    formViewModel.createDuplicate() as T;
                add(duplicateFormViewModel);
              },
        isAvailable: !isReadOnly,
      ),
      ModelAction(
        type: ModelActionType.delete,
        label: ModelActionType.delete.string,
        isDestructive: true,
        onExecute: (onDelete != null)
            ? () => onDelete(formViewModel)
            : () => removeWhere((e) {
                  return formViewModel.formData!.id == e.formData?.id;
                }),
        isAvailable: !isReadOnly,
      ),
    ].where((action) => action.isAvailable).toList();

    return actions;
  }

  List<ModelAction> availablePopupActions(
    T formViewModel, {
    bool isReadOnly = false,
  }) {
    return availableActions(formViewModel, isReadOnly: isReadOnly)
        .where((action) => action.type != ModelActionType.edit)
        .toList();
  }

  List<ModelAction> availableInlineActions(
    T formViewModel, {
    bool isReadOnly = false,
  }) {
    return availableActions(formViewModel, isReadOnly: isReadOnly)
        .where((action) => action.type == ModelActionType.edit)
        .toList();
  }
}
