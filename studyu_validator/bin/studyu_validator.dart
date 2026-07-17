import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:studyu_validator/studyu_validator.dart';

void main(List<String> args) {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addCommand('validate')
    ..addCommand('normalize')
    ..addCommand('schema');

  parser.commands['validate']!
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addFlag('stdin', help: 'Read study JSON from stdin')
    ..addFlag(
      'schema-only',
      negatable: false,
      help: 'Validate against the JSON Schema only, skipping logic checks',
    )
    ..addOption(
      'level',
      defaultsTo: 'draft',
      allowed: ['draft', 'publish'],
      help: 'Validation level: draft or publish',
    )
    ..addOption(
      'section',
      allowed: [
        'study_info',
        'interventions',
        'questionnaire',
        'schedule',
        'consent',
        'observations',
        'report',
        'eligibility',
      ],
      help: 'Run only one section validator instead of the full study check',
    );

  parser.commands['normalize']!
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addFlag('stdin', help: 'Read study JSON from stdin');

  parser.commands['schema']!.addFlag(
    'help',
    abbr: 'h',
    negatable: false,
    help: 'Show this help',
  );

  late ArgResults results;
  try {
    results = parser.parse(args);
  } catch (e) {
    stderr.writeln('Error: $e');
    _printUsage(parser);
    exit(1);
  }

  if (results['help'] as bool) {
    _printUsage(parser);
    exit(0);
  }

  final command = results.command;

  if (command == null) {
    _printUsage(parser);
    exit(1);
  }

  if (command['help'] as bool) {
    stdout.writeln('Usage: studyu_validator ${command.name} [options]');
    stdout.writeln(parser.commands[command.name!]!.usage);
    exit(0);
  }

  switch (command.name) {
    case 'validate':
      _runValidate(command);
    case 'normalize':
      _runNormalize(command);
    case 'schema':
      _runSchema(command);
    default:
      stderr.writeln('Unknown command: ${command.name}');
      exit(1);
  }
}

void _printUsage(ArgParser parser) {
  stdout.writeln(
    'Usage: studyu_validator <validate|normalize|schema> [options]',
  );
  stdout.writeln(parser.usage);
}

void _runValidate(ArgResults command) {
  final levelStr = command['level'] as String;
  final level = levelStr == 'publish'
      ? ValidationLevel.publish
      : ValidationLevel.draft;
  final section = command['section'] as String?;
  final schemaOnly = command['schema-only'] as bool? ?? false;

  if (schemaOnly && section != null) {
    stderr.writeln('Error: --schema-only cannot be combined with --section');
    exit(1);
  }

  final json = _readInput(command);
  ValidationResult result;
  if (schemaOnly) {
    result = validateJsonSchemaOnly(json);
  } else if (section != null) {
    result =
        validateSection(json, section, level) ??
        ValidationResult(
          errors: [
            ValidationError(
              code: 'UNKNOWN_SECTION',
              path: r'$',
              message: 'Unknown section: $section',
              fixHint:
                  'Use one of: study_info, interventions, questionnaire, schedule, consent, observations, report, eligibility',
            ),
          ],
          warnings: [],
        );
  } else {
    result = validateJson(json, level);
  }

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(result.toJson()));
  exit(result.valid ? 0 : 1);
}

void _runNormalize(ArgResults command) {
  final json = _readInput(command);
  stdout.writeln(normalizeJson(json));
  exit(0);
}

void _runSchema(ArgResults command) {
  try {
    stdout.writeln(loadStudySchemaText());
    exit(0);
  } catch (e) {
    stderr.writeln('Error loading schema: $e');
    exit(1);
  }
}

String _readInput(ArgResults command) {
  final useStdin = command['stdin'] as bool? ?? false;
  if (useStdin) {
    final lines = <String>[];
    String? line;
    while ((line = stdin.readLineSync(encoding: utf8)) != null) {
      lines.add(line!);
    }
    return lines.join('\n');
  }
  if (command.rest.isNotEmpty) {
    return File(command.rest.first).readAsStringSync();
  }
  stderr.writeln('Provide a file path or --stdin');
  exit(1);
}
