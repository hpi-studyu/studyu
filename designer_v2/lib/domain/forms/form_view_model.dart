import 'package:reactive_forms/reactive_forms.dart';

enum FormMode {
  create,
  readonly,
  edit,
}

abstract class FormViewModel<T> {
  FormViewModel({
    mode = FormMode.create,
    this.data
  }) : _formMode = mode {
    _saveControlDefaults();
    _applyFormMode();
  }

  T? data;

  FormMode get formMode => _formMode;
  set formMode(FormMode mode) {
    _formMode = mode;
    _applyFormMode();
  }
  FormMode _formMode;

  String get title => titles[formMode] ?? "[Missing title]";
  bool get isValid => form.valid;

  /// Map that stores the default enabled/disabled state for each control in
  /// the [form]
  final Map<String, bool> defaultControlStates = {};

  _saveControlDefaults() {
    for (final entry in form.controls.entries) {
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
      case FormMode.create:
      case FormMode.edit:
        _restoreControlDefaults();
        break;
    }
  }

  void edit(T data) {
    fromData(data);
    formMode = FormMode.edit;
  }

  void read(T data) {
    fromData(data);
    formMode = FormMode.readonly;
  }

  // - Subclass responsibility

  FormGroup get form;
  Map<FormMode, String> get titles;
  Future save();
  void fromData(T data);
  T toData();
}

class FormControlOption<T> {
  final T value;
  final String label;

  FormControlOption(this.value, this.label);
}