import 'dart:async';

import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/utils/debouncer.dart';

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

typedef FormControlUpdateCallback = void Function(AbstractControl control);

abstract class FormViewModel<T> {
  FormViewModel({formData, this.delegate, this.autosave = false}) :
        _formData = formData,
        _formMode = (formData != null) ? FormMode.edit : FormMode.create {
    _restoreControlsFromFormData();
    _formModeUpdated();
    if (autosave) {
      // Push to event queue to avoid listening to update events
      // triggered synchronously during initialization
      Future.delayed(const Duration(milliseconds: 0), enableAutosave);
    }
  }

  T? get formData => _formData;
  set formData(T? formData) => _setFormData(formData);
  T? _formData;

  final bool autosave;

  final IFormViewModelDelegate<FormViewModel<dynamic>>? delegate;

  /// Map that stores the default enabled/disabled state for each control in
  /// the [form]
  final Map<String, bool> _defaultControlStates = {};

  final List<StreamSubscription> _immediateFormChildrenSubscriptions = [];
  Debouncer? _immediateFormChildrenListenerDebouncer;

  FormMode get formMode => _formMode;
  set formMode(FormMode mode) {
    _formMode = mode;
    _formModeUpdated();
  }
  FormMode _formMode;

  String get title => titles[formMode] ?? "[Missing title]";
  bool get isValid => form.valid;

  _setFormData(T? formData, {emitUpdate = true}) {
    _formData = formData;
    if (formData != null) {
      setControlsFrom(formData); // update [form] controls automatically
      if (emitUpdate) {
        form.updateValueAndValidity();
      }
    }
  }

  _saveControlStates() {
    for (final entry in form.controls.entries) {
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

  _restoreControlsFromFormData({emitUpdate = true}) {
    if (formData != null) {
      setControlsFrom(formData!);
    } else {
      initControls();
    }
    if (emitUpdate) {
      form.updateValueAndValidity();
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

  Future save({updateState = true}) {
    if (!form.valid) {
      throw FormInvalidException();
    }

    // Note: order of operations is important here so that the delegate (if any)
    // sees the latest [data] but the previous [formMode]
    final prevFormMode = formMode;
    if (updateState) {
      formData = buildFormData();
    }
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

  void enableAutosave({int debounce = Config.formAutosaveDebounce}) {
    if (_immediateFormChildrenSubscriptions.isNotEmpty) {
      return;
    }
    listenToImmediateFormChildren((control) {
      if (form.valid) {
        // don't update internal state to avoid infinite loop
        save(updateState: false);
      }
    }, debounce: debounce);
  }

  void listenToImmediateFormChildren(FormControlUpdateCallback callback,
      {int debounce = 5000}) {
    // Initialize debounce helper if needed
    if (debounce != 0) {
      _immediateFormChildrenListenerDebouncer ??= Debouncer(milliseconds: debounce);
    }

    for (final control in form.controls.values) {
      void boundListener(event) {
        if (debounce == 0) {
          callback(control);
        } else {
          _immediateFormChildrenListenerDebouncer!(() => callback(control));
        }
      }

      if (control is FormGroup) {
        continue; // don't listen to nested descendants
      }  else if (control is FormArray) {
        final collectionChanges = control.collectionChanges.listen(boundListener);
        // don't subscribe to control.valueChanges
        _immediateFormChildrenSubscriptions.add(collectionChanges);
      } else if (control is FormControl) {
        final valueChanges = control.valueChanges.listen(boundListener);
        _immediateFormChildrenSubscriptions.add(valueChanges);
      }
    }
  }

  void dispose() {
    _immediateFormChildrenListenerDebouncer?.dispose();
    for (final subscription in _immediateFormChildrenSubscriptions) {
      subscription.cancel();
    }
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
