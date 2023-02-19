import 'package:flutter/services.dart';

class NumericalRangeFormatter extends TextInputFormatter {
  NumericalRangeFormatter({
    this.min,
    this.max,
  });

  final int? min;
  final int? max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue;
    } else if (min != null && int.parse(newValue.text) < min!) {
      return newValue.copyWith(text: min.toString());
    } else {
      if (max != null && int.parse(newValue.text) > max!) {
        return newValue.copyWith(text: max.toString());
      }
      return newValue;
    }
  }
}

class StudySequenceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text == '') {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    } else if (newValue.text
        .replaceAll(' ', '')
        .contains(RegExp(r'^[abAB]+$'))) {
      return newValue.copyWith(text: newValue.text.toUpperCase());
    } else {
      return oldValue;
    }
  }
}
