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
    this.onValueChangedImmediate = true,
    this.onStatusChangedImmediate = true,
    this.onValueChangedDebounceTime,
    this.onStatusChangedDebounceTime,
  }) : super() {
    if (onValueChanged != null) {
      final callback = (_onValueChangedDebouncer != null)
          ? (value) =>
              _onValueChangedDebouncer!(callback: () => onValueChanged!(value))
          : onValueChanged;
      valueChanges.listen(callback);
      if (onValueChangedImmediate) {
        // defer synchronous operation to avoid loops from side-effects
        runAsync(() => onValueChanged!(value));
      }
    }

    if (onStatusChanged != null) {
      final callback = (_onStatusChangedDebouncer != null)
          ? (value) => _onStatusChangedDebouncer!(
              callback: () => onStatusChanged!(value))
          : onStatusChanged;
      statusChanged.listen(callback);
      if (onStatusChangedImmediate) {
        // defer synchronous operation to avoid loops from side-effects
        runAsync(() => onStatusChanged!(status));
      }
    }
  }

  late final Debouncer? _onValueChangedDebouncer =
      (onValueChangedDebounceTime != null)
          ? Debouncer(milliseconds: onValueChangedDebounceTime!, leading: false)
          : null;
  late final Debouncer? _onStatusChangedDebouncer =
      (onStatusChangedDebounceTime != null)
          ? Debouncer(
              milliseconds: onStatusChangedDebounceTime!, leading: false)
          : null;

  @override
  void dispose() {
    _onValueChangedDebouncer?.dispose();
    _onStatusChangedDebouncer?.dispose();
    super.dispose();
  }

  final ValueCallback<T?>? onValueChanged;
  final ValueCallback<ControlStatus>? onStatusChanged;
  final bool onValueChangedImmediate;
  final bool onStatusChangedImmediate;
  final int? onStatusChangedDebounceTime;
  final int? onValueChangedDebounceTime;
}
