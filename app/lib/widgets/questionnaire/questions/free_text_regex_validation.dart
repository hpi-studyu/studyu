RegExp? buildFullMatchRegex(String? expression) {
  if (expression == null || expression.isEmpty) {
    return null;
  }

  final fullMatchPattern = '^(?:$expression)\$';
  try {
    return RegExp(fullMatchPattern);
  } on FormatException {
    return null;
  }
}

bool isValidCustomFreeTextInput(String value, String? expression) {
  final regex = buildFullMatchRegex(expression);
  if (regex == null) {
    return false;
  }
  return regex.hasMatch(value);
}
