import 'package:flutter/services.dart';

String normalizeStudySequenceInput(String value) =>
    value.replaceAll(RegExp(r'\s+'), '').toUpperCase();

class NumericalRangeFormatter extends TextInputFormatter {
  NumericalRangeFormatter({this.min, this.max});

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
    final normalized = normalizeStudySequenceInput(newValue.text);

    if (normalized.isNotEmpty && !RegExp(r'^[AB]+$').hasMatch(normalized)) {
      return oldValue;
    }

    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}
