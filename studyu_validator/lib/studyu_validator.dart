import 'dart:convert';
import 'package:studyu_core/core.dart';

export 'package:studyu_core/core.dart'
    show validateStudy, ValidationLevel, ValidationResult, Study;

/// Parse a JSON string into a Study and validate it.
/// Returns a ValidationResult with errors and warnings.
/// Returns an error result if the JSON cannot be parsed or deserialized.
ValidationResult validateJson(String json, ValidationLevel level) {
  final Map<String, dynamic> data;
  try {
    data = jsonDecode(json) as Map<String, dynamic>;
  } catch (e) {
    return ValidationResult(
      errors: [
        ValidationError(
          code: 'PARSE_ERROR',
          path: r'$',
          message: 'Invalid JSON: $e',
          fixHint: 'Provide valid JSON input.',
        ),
      ],
      warnings: [],
    );
  }

  final Study study;
  try {
    study = Study.fromJson(data);
  } catch (e) {
    return ValidationResult(
      errors: [
        ValidationError(
          code: 'DESERIALIZE_ERROR',
          path: r'$',
          message: 'Failed to deserialize Study: $e',
          fixHint: 'Ensure all required fields are present.',
        ),
      ],
      warnings: [],
    );
  }

  return validateStudy(study, level);
}

/// Round-trip a JSON string through Study.fromJson/toJson.
/// Returns canonical JSON string.
String normalizeJson(String json) {
  final Map<String, dynamic> data = jsonDecode(json) as Map<String, dynamic>;
  final study = Study.fromJson(data);
  return const JsonEncoder.withIndent('  ').convert(study.toJson());
}
