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
  FormViewModelCollection(this.formViewModels, this.formArray);

  List<T> formViewModels;
  FormArray formArray;

  /// Staged [FormViewModel]s can be retrieved from the collection using
  /// [findWhere], but are not represented in [formArray] or [formData]
  /// until [commit]ed
  ///
  /// Useful for managing [FormViewModel]s that need to be accessible /
  /// retrievable, but their data should not be rendered yet
  final List<T> stagedViewModels = [];

  List<T> get retrievableViewModels => [...formViewModels, ...stagedViewModels];

  List<D> get formData => formViewModels.map(
          (vm) => vm.buildFormData() as D).toList();

  void add(T formViewModel) {
    if (formViewModels.contains(formViewModel)) {
      return; // maintain unique set
    }
    formViewModels.add(formViewModel);
    formArray.add(formViewModel.form);
  }

  T remove(T formViewModel) {
    // Remove by index since we cannot rely on object identity of [formViewModel.form]
    int idx = formViewModels.indexOf(formViewModel);
    if (idx == -1) {
      throw FormViewModelNotFoundException();
    }
    formArray.removeAt(idx);
    formViewModels.remove(formViewModel);
    return formViewModel;
  }

  T? findWhere(FormViewModelCollectionIterablePredicate<T> predicate) {
    for (final formViewModel in retrievableViewModels) {
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

  bool contains(T formViewModel) {
    return formViewModels.contains(formViewModel);
  }

  void stage(T formViewModel) {
    if (stagedViewModels.contains(formViewModel)) {
      return; // maintain unique set
    }
    stagedViewModels.add(formViewModel);
  }

  T commit(T formViewModel) {
    if (contains(formViewModel)) {
      return formViewModel; // don't recommit existing
    }

    final idx = stagedViewModels.indexOf(formViewModel);
    if (idx == -1) {
      throw FormViewModelNotFoundException();
    }

    add(formViewModel);
    return formViewModel;
  }

  void reset(List<T>? viewModels) {
    formViewModels = [];
    formArray.clear();

    if (viewModels != null) {
      for (final viewModel in viewModels) {
        add(viewModel);
      }
    }

    formArray.updateValueAndValidity();
  }
}
