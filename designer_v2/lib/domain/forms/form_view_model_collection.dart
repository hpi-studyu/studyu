import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';

typedef FormViewModelCollectionIterablePredicate<T extends FormViewModel> = bool Function(T formViewModel);

class FormViewModelNotFoundException implements Exception {}

/// Wrapper around a list of [FormViewModel]s where each [FormViewModel.form]
/// corresponds to a [FormGroup] in a [FormArray] & is automatically synchronized
///
/// Enables reactive re-rendering of forms containing a [FormArray] that is
/// derived from a list of [FormViewModel]s
class FormViewModelCollection<T extends FormViewModel, D> {
  FormViewModelCollection(this.formViewModels);

  final List<T> formViewModels;
  final FormArray formArray = FormArray([]);

  List<D> get formData => formViewModels.map(
          (vm) => vm.buildFormDataFromControls() as D).toList();

  void add(T formViewModel) {
    formViewModels.add(formViewModel);
    formArray.add(formViewModel.form);
  }

  T remove(T formViewModel) {
    // Remove by index since we cannot rely on object identity of [formViewModel.form]
    final idx = formViewModels.indexOf(formViewModel);
    if (idx == -1) {
      throw FormViewModelNotFoundException();
    }
    formArray.removeAt(idx);
    formViewModels.remove(formViewModel);
    return formViewModel;
  }

  T? findWhere(FormViewModelCollectionIterablePredicate<T> predicate) {
    for (final formViewModel in formViewModels) {
      if (predicate(formViewModel)) {
        return formViewModel;
      }
    }
    return null;
  }

  T? removeWhere(FormViewModelCollectionIterablePredicate<T> predicate) {
    for (final formViewModel in formViewModels) {
      if (predicate(formViewModel)) {
        return remove(formViewModel);
      }
    }
    return null;
  }
}
