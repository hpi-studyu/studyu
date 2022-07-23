import 'package:reactive_forms/reactive_forms.dart';

abstract class FormViewModel {
  FormGroup get form;
  String get title;

  bool get isValid => form.valid;

  Future save();
}

class FormControlOption<T> {
  final T value;
  final String label;

  FormControlOption(this.value, this.label);
}
