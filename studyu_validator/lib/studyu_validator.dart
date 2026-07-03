import 'dart:convert';
import 'dart:io';
import 'package:json_schema/json_schema.dart' hide ValidationError;
import 'package:studyu_core/core.dart';

export 'package:studyu_core/core.dart'
    show
        Study,
        ValidationError,
        ValidationLevel,
        ValidationResult,
        validateStudy;

// ---------------------------------------------------------------------------
// Schema loading (cached per process)
// ---------------------------------------------------------------------------

String? _schemaText;
Map<String, dynamic>? _schemaJson;
JsonSchema? _compiledSchema;

/// Walks upward from [Directory.current] to find `.dart_tool/package_config.json`,
/// resolves the `studyu_core` package root, and reads the checked-in schema file.
String _loadStudySchemaText() {
  var schemaText = _schemaText;
  if (schemaText != null) return schemaText;

  final schemaPath = _resolveSchemaPath();
  schemaText = File(schemaPath).readAsStringSync();
  _schemaText = schemaText;
  return schemaText;
}

Map<String, dynamic> _loadStudySchemaJson() {
  var schema = _schemaJson;
  if (schema != null) return schema;
  schema = jsonDecode(_loadStudySchemaText()) as Map<String, dynamic>;
  _schemaJson = schema;
  return schema;
}

JsonSchema _loadCompiledStudySchema() {
  var schema = _compiledSchema;
  if (schema != null) return schema;
  schema = JsonSchema.create(_loadStudySchemaJson());
  _compiledSchema = schema;
  return schema;
}

String _resolveSchemaPath() {
  var dir = Directory.current;
  while (true) {
    final config = File('${dir.path}/.dart_tool/package_config.json');
    if (config.existsSync()) {
      final configJson =
          jsonDecode(config.readAsStringSync()) as Map<String, dynamic>;
      final packages = configJson['packages'] as List<dynamic>;
      for (final pkg in packages) {
        final pkgMap = pkg as Map<String, dynamic>;
        if (pkgMap['name'] == 'studyu_core') {
          final root = pkgMap['rootUri'] as String;
          final String rootPath;
          if (root.startsWith('file://')) {
            rootPath = Uri.parse(root).toFilePath();
          } else if (root.startsWith('/')) {
            rootPath = root;
          } else {
            final configDir = config.parent.path;
            rootPath = Directory('$configDir/$root').resolveSymbolicLinksSync();
          }
          return '$rootPath/lib/src/validators/schema/study.schema.json';
        }
      }
      throw FileSystemException(
        'studyu_core not found in package config at ${config.path}',
      );
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw FileSystemException(
        'Could not find .dart_tool/package_config.json walking upward from ${Directory.current.path}',
      );
    }
    dir = parent;
  }
}

/// Validates [data] against the checked-in JSON Schema.
/// Returns null when valid, or a list of [ValidationError]s on failure.
List<ValidationError>? _validateAgainstSchema(Map<String, dynamic> data) {
  final schema = _loadCompiledStudySchema();
  final result = schema.validate(data);
  if (result.isValid) return null;

  return result.errors
      .map(
        (e) => ValidationError(
          code: 'SCHEMA_ERROR',
          path: _instancePathToJsonPath(e.instancePath),
          message: e.message,
          fixHint:
              'Update the JSON to satisfy study.schema.json before logic validation.',
        ),
      )
      .toList();
}

/// Converts a JSON pointer instancePath (e.g. `/foo/0/bar`) to JSONPath
/// (e.g. `$.foo[0].bar`).
String _instancePathToJsonPath(String instancePath) {
  if (instancePath.isEmpty) return r'$';
  final parts = instancePath.split('/').skip(1).toList();
  final buf = StringBuffer(r'$');
  for (final part in parts) {
    final decoded = part.replaceAll('~1', '/').replaceAll('~0', '~');
    if (_isNumericIndex(decoded)) {
      buf.write('[$decoded]');
    } else if (_isValidIdentifier(decoded)) {
      buf.write('.$decoded');
    } else {
      buf.write("['$decoded']");
    }
  }
  return buf.toString();
}

bool _isNumericIndex(String s) => int.tryParse(s) != null;

bool _isValidIdentifier(String s) =>
    RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$').hasMatch(s);

// ---------------------------------------------------------------------------
// Public API
// ---------------------------------------------------------------------------

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

  // Schema pass — structural validation before deserialization.
  final schemaErrors = _validateAgainstSchema(data);
  if (schemaErrors != null) {
    return ValidationResult(errors: schemaErrors, warnings: []);
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

/// Validate a JSON string against only the JSON Schema, skipping
/// `Study.fromJson` and all logic validators.
ValidationResult validateJsonSchemaOnly(String json) {
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

  final schemaErrors = _validateAgainstSchema(data);
  if (schemaErrors != null) {
    return ValidationResult(errors: schemaErrors, warnings: []);
  }
  return const ValidationResult(errors: [], warnings: []);
}

/// Run a single named section validator.
/// [section] must be one of: study_info, interventions, questionnaire,
/// schedule, consent, observations, report, eligibility.
/// Returns null if [section] is not recognised.
ValidationResult? validateSection(
  String json,
  String section,
  ValidationLevel level,
) {
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

  // Schema pass — structural validation before deserialization.
  final schemaErrors = _validateAgainstSchema(data);
  if (schemaErrors != null) {
    return ValidationResult(errors: schemaErrors, warnings: []);
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

  switch (section) {
    case 'study_info':
      return validateStudyInfo(study, level);
    case 'interventions':
      return validateInterventions(study, level);
    case 'questionnaire':
      return validateQuestionnaire(
        study.questionnaire,
        r'$.questionnaire',
        level,
      );
    case 'schedule':
      return validateSchedule(study, level);
    case 'consent':
      return validateConsent(study, level);
    case 'observations':
      return validateObservations(study, level);
    case 'report':
      return validateReport(study, level);
    case 'eligibility':
      return validateEligibilityConsent(study, level);
    default:
      return null;
  }
}

/// Returns the raw text of the checked-in study schema.
String loadStudySchemaText() => _loadStudySchemaText();

/// Round-trip a JSON string through Study.fromJson/toJson.
/// Returns canonical JSON string.
String normalizeJson(String json) {
  final Map<String, dynamic> data = jsonDecode(json) as Map<String, dynamic>;
  final study = Study.fromJson(data);
  return const JsonEncoder.withIndent('  ').convert(study.toJson());
}
