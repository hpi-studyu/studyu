import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/utils/debouncer.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

typedef ValueCallback<T> = void Function(T value);

class CustomFormControl<T> extends FormControl<T> {
  CustomFormControl({
    super.value,
    super.validators = const [],
    super.asyncValidators = const [],
    super.asyncValidatorsDebounceTime = 250,
    super.touched = false,
    super.disabled = false,
    this.onValueChanged,
    this.onStatusChanged,
    this.onValueChangedDebounceTime,
    this.onStatusChangedDebounceTime,
  }) : super() {
    if (onValueChanged != null) {
      final callback = (_onValueChangedDebouncer != null)
          ? (T? value) =>
              _onValueChangedDebouncer!(callback: () => onValueChanged!(value))
          : onValueChanged;

      valueChanges.listen(callback);
    }

    if (onStatusChanged != null) {
      final callback = (_onStatusChangedDebouncer != null)
          ? (ControlStatus value) => _onStatusChangedDebouncer!(
              callback: () => onStatusChanged!(value),)
          : onStatusChanged;

      statusChanged.listen(callback);
    }
  }

  late final Debouncer? _onValueChangedDebouncer =
      (onValueChangedDebounceTime != null)
          ? Debouncer(milliseconds: onValueChangedDebounceTime!, leading: false)
          : null;
  late final Debouncer? _onStatusChangedDebouncer =
      (onStatusChangedDebounceTime != null)
          ? Debouncer(
              milliseconds: onStatusChangedDebounceTime!, leading: false,)
          : null;

  @override
  void dispose() {
    _onValueChangedDebouncer?.dispose();
    _onStatusChangedDebouncer?.dispose();
    super.dispose();
  }

  final ValueCallback<T?>? onValueChanged;
  final ValueCallback<ControlStatus>? onStatusChanged;
  final int? onStatusChangedDebounceTime;
  final int? onValueChangedDebounceTime;
}

typedef AbstractControlChangedCallback = void Function(AbstractControl control);
typedef FormArrayChangedCallback = void Function(FormArray control);

extension AbstractControlChangedX on AbstractControl {
  void onChanged(AbstractControlChangedCallback callback) {
    valueChanges.listen((event) => callback(this));
  }
}

extension FormArrayChangedX on FormArray {
  void onChanged(FormArrayChangedCallback callback) {
    bool didNotify = false;

    void notifyListener(event) {
      if (didNotify) {
        return;
      }
      callback(this);
      // ensure single listener notification in synchronous control flow
      didNotify = true;
      runAsync(() => didNotify = false);
    }

    valueChanges.listen(notifyListener);
    collectionChanges.listen(notifyListener);
  }
}
