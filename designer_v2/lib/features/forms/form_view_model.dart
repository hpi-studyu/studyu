import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:equatable/equatable.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/utils/debouncer.dart';
import 'package:studyu_designer_v2/utils/performance.dart';
import 'package:studyu_designer_v2/utils/tuple.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

enum FormMode {
  create,
  readonly,
  edit,
}

class FormInvalidException implements Exception {}

class FormConfigException implements Exception {
  FormConfigException([this.message]);
  final String? message;
}

abstract class IFormViewModelDelegate<T extends FormViewModel> {
  Future onSave(T formViewModel, FormMode prevFormMode);
  void onCancel(T formViewModel, FormMode prevFormMode);
}

abstract class IFormGroupController {
  FormGroup get form;
}

class FormControlOption<T> extends Equatable {
  const FormControlOption(this.value, this.label, {this.description});

  final T value;
  final String label;
  final String? description;

  @override
  List<Object?> get props => [value, label, description];
}

typedef FormControlUpdateFutureBuilder = Future Function(AbstractControl control);

abstract class FormViewModel<T> implements IFormGroupController {
  FormViewModel({
    formData,
    this.delegate,
    validationSet,
    this.autosave = false,
  })  : _validationSet = validationSet,
        _formData = formData,
        _formMode = (formData != null) ? FormMode.edit : FormMode.create {
    _setFormData(formData);
    initControls();
    _restoreControlsFromFormData();
    _formModeUpdated();
    _applyValidationSet(validationSet);

    if (autosave) {
      // Push to event queue to avoid listening to update events
      // triggered synchronously during initialization
      runAsync(enableAutosave);
    }
  }

  T? get formData => _formData;
  set formData(T? formData) => _setFormData(formData);
  T? _formData;

  FormMode get formMode => _formMode;
  set formMode(FormMode mode) {
    _formMode = mode;
    _formModeUpdated();
  }

  FormMode _formMode;

  bool get isReadonly => formMode == FormMode.readonly;

  /// Enum that determines which [FormValidationConfig] should be selected
  /// from the [sharedValidationConfig] and applied to the [form].
  ///
  /// If null, the [AbstractControl]s contained in the [form] will be validated
  /// using their default configuration. Otherwise, the default configuration
  /// is discarded & replaced by the respective [FormValidationConfig].
  FormValidationSetEnum? get validationSet => _validationSet;
  FormValidationSetEnum? _validationSet;
  set validationSet(FormValidationSetEnum? validationSet) {
    _validationSet = validationSet;
    _applyValidationSet(validationSet);
  }

  final IFormViewModelDelegate<FormViewModel<dynamic>>? delegate;

  final bool autosave;

  final List<StreamSubscription> _immediateFormChildrenSubscriptions = [];
  Debouncer? _immediateFormChildrenListenerDebouncer;

  CancelableOperation? _autosaveOperation;

  /// Map that stores the default enabled/disabled state for each control in
  /// the [form]
  final Map<String, bool> _defaultControlStates = {};

  /// Map that stores the default [AbstractControl.validators] and
  /// [AbstractControl.asyncValidators] for each control in the [form]
  final Map<String, Tuple<List<Validator>, List<AsyncValidator>>> _defaultControlValidators = {};

  /// Flag indicating whether the current [form] data is different from
  /// the most recently set [formData]
  ///
  /// The comparison is based on the [form]'s JSON [form.value], including
  /// values from disabled controls (which is not the case by default) so
  /// that controls can be marked as disabled when needed for the UI
  /// without affecting the dirty status.
  ///
  /// Note: for the JSON-based comparison to work, all [FormControl] and
  /// [FormArray] types must be JSON-serializable
  ///
  /// Note: [AbstractControl.dirty] does not work reliably when the [form]'s
  /// values are initialized in [setControlsFrom] (controls that are set
  /// programmatically are incorrectly marked as dirty without any user input).
  bool get isDirty {
    _rememberDefaultControlStates();

    for (final control in form.controls.values) {
      control.markAsEnabled(emitEvent: false, updateParent: false);
    }
    final isEqual = jsonEncode(prevFormValue) == jsonEncode(form.value);

    for (final control in form.controls.values) {
      control.markAsEnabled(emitEvent: false, updateParent: false);
    }
    _restoreControlStates(emitEvent: false, updateParent: false);

    return !isEqual;
  }

  /// The [form]'s JSON value after initializing the controls with [formData]
  JsonMap? prevFormValue;

  /// Key used internally for storing properties of the [form] itself
  static const _formKey = '__form';

  _setFormData(T? formData) {
    _formData = formData;
    if (formData != null) {
      setControlsFrom(formData); // update [form] controls automatically
    }
    prevFormValue = {...form.value};
    form.updateValueAndValidity();
  }

  _rememberDefaultControlStates() {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      if (!_defaultControlStates.containsKey(controlName)) {
        _defaultControlStates[controlName] = control.enabled;
      }
    }
  }

  _rememberDefaultControlValidators() {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      if (!_defaultControlValidators.containsKey(controlName)) {
        _defaultControlValidators[controlName] = Tuple(control.validators, control.asyncValidators);
      }
    }
    if (!_defaultControlValidators.containsKey(_formKey)) {
      _defaultControlValidators[_formKey] = Tuple(form.validators, form.asyncValidators);
    }
  }

  Tuple<List<Validator>, List<AsyncValidator>>? _getDefaultValidators(String controlName) {
    return _defaultControlValidators[controlName];
  }

  _disableAllControls() {
    for (final control in form.controls.values) {
      control.markAsDisabled();
    }
    assert(form.allControlsDisabled());
  }

  _restoreControlStates({emitEvent = true, updateParent = true}) {
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      final isEnabledByDefault = _defaultControlStates[controlName] ?? true;
      if (isEnabledByDefault) {
        control.markAsEnabled(emitEvent: emitEvent, updateParent: updateParent);
      } else {
        control.markAsDisabled(emitEvent: emitEvent, updateParent: updateParent);
      }
    }
  }

  _formModeUpdated() {
    switch (formMode) {
      case FormMode.readonly:
        _rememberDefaultControlStates();
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
      setControlsFrom(formData as T);
      form.updateValueAndValidity();
    }
  }

  void revalidate() {
    _applyValidationSet(validationSet);
  }

  /// Updates & re-evaluates [AbstractControl.validators] and
  /// [AbstractControl.asyncValidators] for all [FormControl]'s in the
  /// current [form] (or the [FormGroup] itself) with the validators of
  /// the [FormValidationConfig]corresponding to the given [validationSet]
  /// (as defined in [sharedValidationConfig])
  ///
  /// Note: this will only look at immediate child controls of the [form]
  /// and not walk the whole tree
  void _applyValidationSet(FormValidationSetEnum? validationSet) {
    if (validationSet == null) {
      return; // retain default form validators
    }
    final formValidationConfig = sharedValidationConfig[validationSet];
    if (formValidationConfig == null) {
      throw FormConfigException("Failed to lookup FormValidationConfig for key: $validationSet");
    }

    // Build mapping from control => merged config
    final Map<AbstractControl, FormControlValidation> controlConfigs = {};
    for (final controlValidationConfig in formValidationConfig) {
      final existingConfig = controlConfigs[controlValidationConfig.control];
      final mergedConfig = controlValidationConfig.merge(existingConfig);
      controlConfigs[controlValidationConfig.control] = mergedConfig;
    }

    // Store defaults for each control if it's not known yet
    // Will not override defaults when the control is already known
    _rememberDefaultControlValidators();

    // Helper function to reset & change the validators on a single control
    resetAndUpdateControlValidators(String controlName, AbstractControl control) {
      // Reset the control validators to its cached defaults
      final defaultValidators = _getDefaultValidators(controlName);
      assert(defaultValidators?.first != null);
      assert(defaultValidators?.second != null);

      control.setValidators(defaultValidators?.first ?? [], emitEvent: false);
      control.setAsyncValidators(defaultValidators?.second ?? [], emitEvent: false);

      // Apply control-specific config (if any)
      //
      // Note: if there is no config defined for this control, it will
      // be reset to its cached defaults (from the code section above)
      // as opposed to being cleared completely
      if (controlConfigs.containsKey(control)) {
        final controlConfig = controlConfigs[control]!;
        control.setValidators(controlConfig.validators, emitEvent: false);
        if (controlConfig.asyncValidators != null) {
          control.setAsyncValidators(controlConfig.asyncValidators!, emitEvent: false);
        }
        control.validationMessages = controlConfig.validationMessages;
      }

      // Note: [FormGroup.updateValueAndValidity] does *not* revalidate
      // any child controls! Hence we need to revalidate them explicitly
      control.updateValueAndValidity(updateParent: false, emitEvent: false);
    }

    // Reset & update the validators of all direct child controls
    for (final entry in form.controls.entries) {
      final controlName = entry.key;
      final control = entry.value;
      resetAndUpdateControlValidators(controlName, control);
    }

    // Reset & update the validators of the form itself
    resetAndUpdateControlValidators(_formKey, form);
  }

  String get title => titles[formMode] ?? "[Missing title]";
  bool get isValid => form.valid;

  void read([T? formData]) {
    if (formData != null) {
      this.formData = formData;
    }
    formMode = FormMode.readonly;
  }

  Future save() async {
    if (!form.valid) {
      throw FormInvalidException();
    }

    // Note: order of operations is important here so that the delegate (if any)
    // sees the latest [data] but the previous [formMode]
    final prevFormMode = formMode;

    if (isDirty) {
      final currentFormData = buildFormData();
      // Reinitialize the viewmodel with the [form]'s current data, resulting
      // in an update to the [form] controls from calling [_setFormData]
      // and [setControlsFrom] internally
      formData = currentFormData;
    } else {
      // Do nothing - this is important!
      // Otherwise we may enter an infinite loop from calling [_setFormData]
      // and [setControlsFrom] internally. Calling [setControlsFrom] may result
      // in update events emitted by the reactive controls as their values are
      // re-initialized, which re-triggers the valueChanges stream subscription
      // used for autosaving (entering the infinite loop)
    }
    await delegate?.onSave(this, prevFormMode);

    // Put form into edit mode with saved data
    if (prevFormMode == FormMode.create) {
      formMode = FormMode.edit;
    }

    return Future.value(true);
  }

  Future<void> cancel() {
    if (formMode != FormMode.readonly) {
      _restoreControlsFromFormData();
    }
    delegate?.onCancel(this, formMode);

    return Future.value(null);
  }

  void enableAutosave({
    int debounce = Config.formAutosaveDebounce,
    onlyValid = true,
  }) {
    if (_immediateFormChildrenSubscriptions.isNotEmpty) {
      return;
    }
    listenToImmediateFormChildren((control) {
      final saveFuture = save();
      _autosaveOperation = CancelableOperation.fromFuture(saveFuture);
      return saveFuture;
    }, debounce: debounce);
  }

  void listenToImmediateFormChildren(FormControlUpdateFutureBuilder futureBuilder, {int debounce = 1500}) {
    // Initialize debounce helper if needed
    if (debounce != 0) {
      _immediateFormChildrenListenerDebouncer ??= Debouncer(milliseconds: debounce, leading: false);
    }

    for (final control in form.controls.values) {
      void boundListener(event) {
        if (debounce == 0) {
          futureBuilder(control);
        } else {
          _immediateFormChildrenListenerDebouncer!(futureBuilder: () => futureBuilder(control));
        }
      }

      if (control is FormGroup) {
        continue; // don't listen to nested descendants
      } else if (control is FormArray) {
        final collectionChanges = control.collectionChanges.listen(boundListener);
        // don't subscribe to control.valueChanges
        _immediateFormChildrenSubscriptions.add(collectionChanges);
      } else if (control is FormControl) {
        final valueChanges = control.valueChanges.listen(boundListener);
        _immediateFormChildrenSubscriptions.add(valueChanges);
      }
    }
  }

  /// Call after changing / adding / removing the child controls in [form]
  /// to perform necessary housekeeping
  markFormGroupChanged() {
    revalidate();
    _formModeUpdated();
    form.updateValueAndValidity();
  }

  void dispose() {
    _immediateFormChildrenListenerDebouncer?.dispose();
    _autosaveOperation?.cancel();
    /*for (final subscription in _immediateFormChildrenSubscriptions) {
      subscription.pause();
    }*/
  }

  // - Subclass responsibility

  Map<FormMode, String> get titles;

  /// The available set of validation configurations for the [form] managed
  /// by this view model.
  ///
  /// One of the [FormValidationConfig]s is chosen at runtime based on the
  /// current [validationSet] and applied to the [form].
  FormValidationConfigSet get sharedValidationConfig => {};

  /// Initialize the values of all [FormControl]s in the [form]
  void setControlsFrom(T data);
  T buildFormData();

  void initControls() {
    // subclass responsibility (optional)
  }
}
