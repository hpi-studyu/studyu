import 'package:reactive_forms/reactive_forms.dart';

enum FormMode {
  create,
  readonly,
  edit,
}

class FormInvalidException implements Exception {}

abstract class FormViewModel<T> {
  FormViewModel({
    //mode = FormMode.create,
    formData,
    this.delegate
  }) : _data = formData,/* _formMode = mode*/
        _formMode = (formData != null) ? FormMode.edit : FormMode.create {
    if (formData != null) {
      fromData(formData!);
    } else {
      setFormDefaults();
    }

    // TODO Why does this break?
    //_saveControlDefaults();
    _applyFormMode();
  }

  T? get data => _data;
  set data(T? data) {
    _data = data;
    if (data != null) {
      fromData(data); // update [form] automatically
    }
  }
  T? _data;

  //T? data;
  final IFormViewModelDelegate? delegate;

  FormMode get formMode => _formMode;
  set formMode(FormMode mode) {
    _formMode = mode;
    _applyFormMode(); // TODO is this what we always want to do?
  }
  FormMode _formMode;

  String get title => titles[formMode] ?? "[Missing title]";
  bool get isValid => form.valid;

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
    this.data = data;
    //fromData(data);
    formMode = FormMode.edit;
  }

  void read(T data) {
    this.data = data;
    //fromData(data);
    formMode = FormMode.readonly;
  }

  void refreshData() {
    data = toData();
    //fromData(toData());
  }

  // - Subclass responsibility

  FormGroup get form;
  Map<FormMode, String> get titles;
  /// Initialize the values of all [FormControl]s in the [form]
  void fromData(T data);
  T toData();

  Future save() {
    if (!form.valid) {
      throw FormInvalidException();
    }
    // Note: order of operations is important here so that the delegate (if any)
    // sees the latest [data] but the previous [formMode]
    final prevFormMode = formMode;
    refreshData();
    delegate?.onSave(this, prevFormMode);

    // Put form into edit mode with saved data
    if (prevFormMode == FormMode.create) {
      formMode = FormMode.edit;
    }

    return Future.value(null);
  }

  Future<void> close() {
    delegate?.onClose(this, formMode);
    return Future.value(null); // no-op
  }

  void setFormDefaults() {
    // subclass responsibility (optional)
  }
}

abstract class IFormViewModelDelegate<T extends FormViewModel> {
  void onSave(T formViewModel, FormMode prevFormMode);
  void onClose(T formViewModel, FormMode prevFormMode);
}

// TODO: get rid of this in favor of delegate pattern?
abstract class ChildFormViewModel<T, P extends FormViewModel>
    extends FormViewModel<T> {

  ChildFormViewModel({
    super.formData,
    required this.parent,
  });

  P parent;

  @override
  Future save() async {
    final newData = toData();
    print(newData);
    return parent.save();
  }
}

class FormControlOption<T> {
  final T value;
  final String label;

  FormControlOption(this.value, this.label);
}