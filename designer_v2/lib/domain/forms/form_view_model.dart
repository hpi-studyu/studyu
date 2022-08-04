import 'package:reactive_forms/reactive_forms.dart';

enum FormMode {
  create,
  readonly,
  edit,
}

class FormInvalidException implements Exception {}

abstract class IFormViewModelDelegate<T extends FormViewModel> {
  void onSave(T formViewModel, FormMode prevFormMode);
  void onCancel(T formViewModel, FormMode prevFormMode);
}

class FormControlOption<T> {
  final T value;
  final String label;

  FormControlOption(this.value, this.label);
}

abstract class FormViewModel<T> {
  FormViewModel({formData, this.delegate}) :
        _formData = formData,
        _formMode = (formData != null) ? FormMode.edit : FormMode.create {
    _restoreControlsFromFormData();
    _formModeUpdated();
  }

  T? get formData => _formData;
  set formData(T? formData) {
    _formData = formData;
    if (formData != null) {
      setControlsFrom(formData); // update [form] controls automatically
      form.updateValueAndValidity();
    }
  }
  T? _formData;

  final IFormViewModelDelegate<FormViewModel<dynamic>>? delegate;

  /// Map that stores the default enabled/disabled state for each control in
  /// the [form]
  final Map<String, bool> _defaultControlStates = {};

  FormMode get formMode => _formMode;
  set formMode(FormMode mode) {
    _formMode = mode;
    _formModeUpdated();
  }
  FormMode _formMode;

  String get title => titles[formMode] ?? "[Missing title]";
  bool get isValid => form.valid;

  _saveControlStates() {
    for (final entry in form.controls.entries) {
      entry.value as FormArray;
      final controlName = entry.key;
      final control = entry.value;
      _defaultControlStates[controlName] = control.enabled;
    }
  }

  _disableAllControls() {
    for (final control in form.controls.values) {
      control.markAsDisabled();
    }
    assert(form.allControlsDisabled());
  }

  _restoreControlStates() {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      final isEnabledByDefault = _defaultControlStates[controlName] ?? true;
      if (isEnabledByDefault) {
        control.markAsEnabled();
      } else {
        control.markAsDisabled();
      }
    }
  }

  _formModeUpdated() {
    switch (formMode) {
      case FormMode.readonly:
        _saveControlStates();
        _disableAllControls();
        break;
      case FormMode.create:
      case FormMode.edit:
        _restoreControlStates();
        break;
    }
  }

  _restoreControlsFromFormData() {
    if (formData != null) {
      setControlsFrom(formData!);
    } else {
      initControls();
    }
    form.updateValueAndValidity();
  }

  void edit(T formData) {
    this.formData = formData;
    formMode = FormMode.edit;
  }

  void read(T formData) {
    this.formData = formData;
    formMode = FormMode.readonly;
  }

  Future save() {
    if (!form.valid) {
      throw FormInvalidException();
    }
    // Note: order of operations is important here so that the delegate (if any)
    // sees the latest [data] but the previous [formMode]
    final prevFormMode = formMode;
    formData = buildFormData();
    delegate?.onSave(this, prevFormMode);

    // Put form into edit mode with saved data
    if (prevFormMode == FormMode.create) {
      formMode = FormMode.edit;
    }

    return Future.value(null);
  }

  Future<void> cancel() {
    _restoreControlsFromFormData();
    delegate?.onCancel(this, formMode);

    return Future.value(null);
  }

  // - Subclass responsibility

  FormGroup get form;
  Map<FormMode, String> get titles;

  /// Initialize the values of all [FormControl]s in the [form]
  void setControlsFrom(T data);
  T buildFormData();

  void initControls() {
    // subclass responsibility (optional)
  }
}
