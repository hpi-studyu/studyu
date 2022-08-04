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
  FormViewModel({
    formData,
    this.delegate
  }) : _formData = formData,
        _formMode = (formData != null) ? FormMode.edit : FormMode.create {
    _restoreControlsFromFormData();
    // TODO: do we still need this?
    //_saveControlDefaults();
    _applyFormMode();
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

  FormMode get formMode => _formMode;
  set formMode(FormMode mode) {
    _formMode = mode;
    _applyFormMode(); // TODO is this what we always want to do?
  }
  FormMode _formMode;

  String get title => titles[formMode] ?? "[Missing title]";
  bool get isValid => form.valid;

  _restoreControlsFromFormData() {
    if (formData != null) {
      setControlsFrom(formData!);
    } else {
      initControls();
    }
    form.updateValueAndValidity();
  }

  /*
  TODO: do we still need this?

  /// Map that stores the default enabled/disabled state for each control in
  /// the [form]
  final Map<String, bool> defaultControlStates = {};

  _saveControlDefaults() {
    for (final entry in form.controls.entries) {
      entry.value as FormArray;
      final controlName = entry.key;
      final control = entry.value;
      defaultControlStates[controlName] = control.enabled;
    }
  }

  _restoreControlDefaults() {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      final isEnabledByDefault = defaultControlStates[controlName] ?? true;
      if (isEnabledByDefault) {
        control.markAsEnabled();
      } else {
        control.markAsDisabled();
      }
    }
  }
   */

  _disableAllControls() {
    for (final control in form.controls.values) {
      control.markAsDisabled();
    }
  }

  _applyFormMode() {
    switch (formMode) {
      case FormMode.readonly:
        _disableAllControls();
        break;
        /* TODO: do we still need this?
      case FormMode.create:
      case FormMode.edit:
        _restoreControlDefaults();
        break;
         */
    }
  }

  void edit(T formData) {
    this.formData = formData;
    formMode = FormMode.edit;
  }

  void read(T formData) {
    this.formData = formData;
    formMode = FormMode.readonly;
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
}
