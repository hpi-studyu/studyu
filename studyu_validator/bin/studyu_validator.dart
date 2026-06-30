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
    ..addOption('level',
        defaultsTo: 'draft',
        allowed: ['draft', 'publish'],
        help: 'Validation level: draft or publish');

  parser.commands['normalize']!
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addFlag('stdin', help: 'Read study JSON from stdin');

  parser.commands['schema']!
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Show this help')
    ..addOption('entity',
        defaultsTo: 'Study',
        help: 'Entity name: Study, Intervention, Question');

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
  stdout.writeln('Usage: studyu_validator <validate|normalize|schema> [options]');
  stdout.writeln(parser.usage);
}

void _runValidate(ArgResults command) {
  final json = _readInput(command);
  final levelStr = command['level'] as String;
  final level =
      levelStr == 'publish' ? ValidationLevel.publish : ValidationLevel.draft;

  final result = validateJson(json, level);
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(result.toJson()));
  exit(result.valid ? 0 : 1);
}

void _runNormalize(ArgResults command) {
  final json = _readInput(command);
  stdout.writeln(normalizeJson(json));
  exit(0);
}

void _runSchema(ArgResults command) {
  final entity = command['entity'] as String;
  stdout.writeln('Schema for $entity: see studyu://docs/$entity in studyu_mcp');
  exit(0);
}

String _readInput(ArgResults command) {
  final useStdin = command['stdin'] as bool? ?? false;
  if (useStdin) {
    // Read all stdin lines — handles multi-line JSON
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
