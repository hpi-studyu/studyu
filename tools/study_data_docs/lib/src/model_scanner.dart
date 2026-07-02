/// Scans Dart source files and their generated `.g.dart` counterparts to
/// extract field information for documentation generation.
///
/// Uses `package:analyzer` version 12.x for accurate symbol extraction.
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:path/path.dart' as p;

/// A single scanned field from a Dart class.
class ScannedField {
  final String name;
  final String dartType;
  final String jsonKey; // wire JSON key (may differ from Dart field name)
  final bool required;
  final bool nullable;
  final bool includeInJson; // false when @JsonKey(includeToJson: false)

  /// Source-level default value as a string, e.g. `'[]'`, `'true'`, `'0'`.
  /// Null when the field has no initializer.
  final String? defaultValue;

  const ScannedField({
    required this.name,
    required this.dartType,
    required this.jsonKey,
    required this.required,
    required this.nullable,
    this.includeInJson = true,
    this.defaultValue,
  });
}

/// The result of scanning one class.
class ScannedClass {
  final String name;
  final String sourceFile; // relative path from repo root
  final List<ScannedField> fields;

  /// Wire discriminator values for this concrete class.
  /// E.g. `{'type': 'boolean'}` for BooleanQuestion.
  final Map<String, String> discriminatorValues;

  /// Names of all direct and inherited superclasses/interfaces.
  final Set<String> superTypes;

  const ScannedClass({
    required this.name,
    required this.sourceFile,
    required this.fields,
    this.discriminatorValues = const {},
    this.superTypes = const {},
  });
}

/// Scans all in-scope Dart model files and returns a map of class name →
/// [ScannedClass].
///
/// [modelsDir] should be the absolute path to `core/lib/src/models/`.
/// [repoRoot] is used to produce relative source file paths.
Future<Map<String, ScannedClass>> scanModels({
  required String modelsDir,
  required String repoRoot,
}) async {
  final dartFiles = _findDartSources(modelsDir);
  final generatedContracts = _loadGeneratedJsonContracts(dartFiles);

  final collection = AnalysisContextCollection(
    includedPaths: dartFiles.map((f) => p.normalize(f)).toList(),
  );

  // First pass: collect all resolved units so we can back-reference AST nodes.
  final units = <String, ResolvedUnitResult>{};
  for (final dartFile in dartFiles) {
    final normalised = p.normalize(dartFile);
    final context = collection.contextFor(normalised);
    final parsed = await context.currentSession.getResolvedUnit(normalised);
    if (parsed is ResolvedUnitResult) units[normalised] = parsed;
  }

  final result = <String, ScannedClass>{};

  for (final entry in units.entries) {
    final dartFile = entry.key;
    final parsed = entry.value;

    for (final decl in parsed.unit.declarations) {
      if (decl is! ClassDeclaration) continue;

      final fragment = decl.declaredFragment;
      if (fragment == null) continue;

      final classElement = fragment.element;
      final className = decl.namePart.typeName.lexeme;

      final fields = _extractFields(
        classElement,
        parsed.unit,
        generatedContracts[dartFile]?[className],
      );
      final discriminators = _extractDiscriminators(decl);
      final superTypes = _extractSuperTypes(classElement);
      final relPath = p.relative(dartFile, from: repoRoot);

      result[className] = ScannedClass(
        name: className,
        sourceFile: relPath,
        fields: fields,
        discriminatorValues: discriminators,
        superTypes: superTypes,
      );
    }
  }

  return result;
}

/// Builds a discriminator map for an abstract dispatcher class by collecting
/// the concrete wire values from all its known subclasses.
///
/// [dispatcherClass] is the abstract class name (e.g. `'Question'`).
/// [fieldName] is the JSON discriminator key (e.g. `'type'`).
/// [allClasses] is the full scan result.
///
/// Returns `{'type': {'boolean', 'choice', 'scale', ...}}`.
Map<String, Set<String>> buildDispatcherDiscriminators({
  required String dispatcherClass,
  required String fieldName,
  required Map<String, ScannedClass> allClasses,
}) {
  final matchingClasses = allClasses.values
      .where((cls) => cls.superTypes.contains(dispatcherClass))
      .toList(growable: false);
  final candidates = matchingClasses.isEmpty
      ? allClasses.values
      : matchingClasses;
  final values = <String>{};
  for (final cls in candidates) {
    final wireValue = cls.discriminatorValues[fieldName];
    if (wireValue == null || wireValue.isEmpty) continue;
    values.add(wireValue);
  }
  if (values.isEmpty) return {};
  return {fieldName: values};
}

/// Returns all `.dart` source files (not `.g.dart`) under [dir].
List<String> _findDartSources(String dir) {
  final result = <String>[];
  final directory = Directory(dir);
  if (!directory.existsSync()) return result;

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File &&
        entity.path.endsWith('.dart') &&
        !entity.path.endsWith('.g.dart')) {
      result.add(entity.path);
    }
  }
  return result;
}

/// Extracts serialisable fields from a class element, including fields
/// inherited from superclasses (but not from Object).
///
/// Fields are returned in declaration order: superclass fields first,
/// then subclass fields. [unit] is used to extract initializer source text.
/// [generatedContract] mirrors the generated serializer's actual JSON keys and
/// encode participation when available.
List<ScannedField> _extractFields(
  ClassElement element,
  CompilationUnit unit,
  _GeneratedJsonContract? generatedContract,
) {
  // Build inheritance chain (subclass → superclass), reverse to superclass-first.
  final chain = <ClassElement>[];
  ClassElement? current = element;
  while (current != null && current.name != 'Object') {
    chain.add(current);
    current = current.supertype?.element as ClassElement?;
  }

  final seen = <String, ClassElement>{};
  for (final cls in chain.reversed) {
    final name = cls.name;
    if (name != null) seen[name] = cls;
  }

  // Build a map from field name → initializer source text from the AST.
  // This captures non-const defaults like `= []`, `= ''`, `= true`.
  final initializerText = <String, String>{};
  for (final decl in unit.declarations) {
    if (decl is ClassDeclaration) {
      final body = decl.body;
      if (body is! BlockClassBody) continue;
      for (final member in body.members) {
        if (member is FieldDeclaration && !member.isStatic) {
          for (final variable in member.fields.variables) {
            final init = variable.initializer;
            if (init != null) {
              initializerText[variable.name.lexeme] = init.toSource().trim();
            }
          }
        }
      }
    }
  }

  final fields = <ScannedField>[];
  final seenJsonKeys = <String>{};

  for (final cls in seen.values) {
    for (final field in cls.fields) {
      if (field.isStatic) continue;
      if (!field.isOriginDeclaration) continue;

      final fieldName = field.name;
      if (fieldName == null) continue;
      if (fieldName.startsWith('_')) continue; // skip private backing fields

      final jsonKeyAnnotation = _findJsonKey(field);

      final bool includeToJson =
          jsonKeyAnnotation?.getField('includeToJson')?.toBoolValue() ?? true;
      final bool includeFromJson =
          jsonKeyAnnotation?.getField('includeFromJson')?.toBoolValue() ?? true;
      final generatedField = generatedContract?.fieldsByName[fieldName];
      final String jsonKeyName =
          generatedField?.jsonKey ??
          jsonKeyAnnotation?.getField('name')?.toStringValue() ??
          fieldName;

      if (!includeToJson && !includeFromJson) continue;
      if (seenJsonKeys.contains(jsonKeyName)) continue;
      seenJsonKeys.add(jsonKeyName);

      final dartType = field.type.getDisplayString();
      final nullable =
          field.type.nullabilitySuffix == NullabilitySuffix.question;

      // Extract default value: prefer @JsonKey(defaultValue:), fall back to
      // source-level initializer text.
      final jsonDefaultObj = jsonKeyAnnotation?.getField('defaultValue');
      String? defaultVal = generatedField?.defaultValue;
      final hasGeneratedDefault = generatedField?.hasDefaultValue ?? false;
      if (!hasGeneratedDefault &&
          jsonDefaultObj != null &&
          !jsonDefaultObj.isNull) {
        defaultVal = _dartObjectToSource(jsonDefaultObj);
      } else if (!hasGeneratedDefault && field.hasInitializer) {
        defaultVal = initializerText[fieldName];
      }

      fields.add(
        ScannedField(
          name: fieldName,
          jsonKey: jsonKeyName,
          dartType: dartType,
          required: !nullable && !field.hasInitializer,
          nullable: nullable,
          includeInJson: generatedField?.includeToJson ?? includeToJson,
          defaultValue: defaultVal,
        ),
      );
    }
  }

  return fields;
}

Set<String> _extractSuperTypes(ClassElement element) {
  final result = <String>{};
  for (final supertype in element.allSupertypes) {
    final name = supertype.element.name;
    if (name != null && name != 'Object') result.add(name);
  }
  return result;
}

Map<String, Map<String, _GeneratedJsonContract>> _loadGeneratedJsonContracts(
  List<String> dartFiles,
) {
  final result = <String, Map<String, _GeneratedJsonContract>>{};
  for (final dartFile in dartFiles) {
    final generatedPath = p.setExtension(dartFile, '.g.dart');
    final file = File(generatedPath);
    if (!file.existsSync()) continue;

    final parsed = parseString(
      content: file.readAsStringSync(),
      path: generatedPath,
    );
    final contracts = _parseGeneratedJsonContracts(parsed.unit);
    if (contracts.isNotEmpty) result[p.normalize(dartFile)] = contracts;
  }
  return result;
}

Map<String, _GeneratedJsonContract> _parseGeneratedJsonContracts(
  CompilationUnit unit,
) {
  final result = <String, _GeneratedJsonContract>{};

  for (final declaration in unit.declarations) {
    if (declaration is! FunctionDeclaration) continue;
    final name = declaration.name.lexeme;
    final toJsonClassMatch = RegExp(r'^_\$(.+)ToJson$').firstMatch(name);
    if (toJsonClassMatch == null) continue;

    final className = toJsonClassMatch.group(1)!;
    final contract = result.putIfAbsent(className, _GeneratedJsonContract.new);
    final body = declaration.functionExpression.body;
    final expression = body is ExpressionFunctionBody ? body.expression : null;
    if (expression is! SetOrMapLiteral) continue;

    for (final element in expression.elements) {
      if (element is! MapLiteralEntry) continue;
      final keyExpression = element.key;
      final key = keyExpression is StringLiteral
          ? keyExpression.stringValue
          : null;
      if (key == null) continue;

      final fieldName = _instanceFieldName(element.value);
      if (fieldName == null) continue;
      contract.fieldsByName[fieldName] = _GeneratedJsonField(
        jsonKey: key,
        includeToJson: true,
      );
    }
  }

  for (final declaration in unit.declarations) {
    if (declaration is! FunctionDeclaration) continue;
    final name = declaration.name.lexeme;
    final fromJsonClassMatch = RegExp(r'^_\$(.+)FromJson$').firstMatch(name);
    if (fromJsonClassMatch == null) continue;

    final className = fromJsonClassMatch.group(1)!;
    final contract = result.putIfAbsent(className, _GeneratedJsonContract.new);
    final source = declaration.toSource();
    for (final field in contract.fieldsByName.values) {
      final defaultValue = _generatedDefaultForKey(source, field.jsonKey);
      if (defaultValue != null) {
        field.defaultValue = defaultValue;
        field.hasDefaultValue = true;
      }
    }
  }

  return result;
}

String? _instanceFieldName(Expression expression) {
  Expression current = expression;

  while (true) {
    if (current is MethodInvocation) {
      final target = current.target;
      if (target == null) return null;
      current = target;
      continue;
    }

    if (current is PropertyAccess) {
      if (current.target?.toSource() == 'instance') {
        return current.propertyName.name;
      }
      final target = current.target;
      if (target == null) return null;
      current = target;
      continue;
    }

    if (current is PrefixedIdentifier && current.prefix.name == 'instance') {
      return current.identifier.name;
    }

    return null;
  }
}

String? _generatedDefaultForKey(String source, String jsonKey) {
  final jsonRead = "json['$jsonKey']";
  final readIndex = source.indexOf(jsonRead);
  if (readIndex == -1) return null;

  final defaultIndex = source.indexOf('??', readIndex + jsonRead.length);
  if (defaultIndex == -1) return null;

  final nextJsonRead = source.indexOf("json['", readIndex + jsonRead.length);
  if (nextJsonRead != -1 && nextJsonRead < defaultIndex) return null;

  final start = defaultIndex + 2;
  final semicolon = source.indexOf(';', start);
  final terminator = semicolon == -1 ? source.length : semicolon;
  final candidates = [
    source.indexOf(',\n', start),
    source.indexOf(',\r\n', start),
    terminator,
  ].where((i) => i != -1 && i <= terminator).toList()..sort();
  if (candidates.isEmpty) return null;
  return source.substring(start, candidates.first).trim();
}

class _GeneratedJsonContract {
  final Map<String, _GeneratedJsonField> fieldsByName = {};
}

class _GeneratedJsonField {
  final String jsonKey;
  final bool includeToJson;
  String? defaultValue;
  bool hasDefaultValue = false;

  _GeneratedJsonField({required this.jsonKey, required this.includeToJson});
}

/// Finds the `@JsonKey(...)` constant value for a [FieldElement], or null.
DartObject? _findJsonKey(FieldElement field) {
  for (final annotation in field.metadata.annotations) {
    final element = annotation.element;
    if (element is ConstructorElement) {
      if (element.enclosingElement.name == 'JsonKey') {
        return annotation.computeConstantValue();
      }
    }
  }
  return null;
}

/// Converts a [DartObject] to a human-readable source string for display.
String? _dartObjectToSource(DartObject obj) {
  final boolVal = obj.toBoolValue();
  if (boolVal != null) return boolVal.toString();
  final intVal = obj.toIntValue();
  if (intVal != null) return intVal.toString();
  final doubleVal = obj.toDoubleValue();
  if (doubleVal != null) return doubleVal.toString();
  final strVal = obj.toStringValue();
  if (strVal != null) return "'$strVal'";
  final listVal = obj.toListValue();
  if (listVal != null) return '[]';
  final mapVal = obj.toMapValue();
  if (mapVal != null) return '{}';
  return null;
}

/// Extracts discriminator constant values from a concrete class declaration.
///
/// Looks for `static const String xyzType = 'value'` patterns that represent
/// the wire value used in polymorphic dispatchers.
Map<String, String> _extractDiscriminators(ClassDeclaration decl) {
  final result = <String, String>{};

  final body = decl.body;
  if (body is! BlockClassBody) return result;

  for (final member in body.members) {
    if (member is FieldDeclaration && member.isStatic) {
      if (!member.fields.isConst) continue;
      for (final variable in member.fields.variables) {
        final varName = variable.name.lexeme;
        // Skip keyType — it's the field name constant, not a wire value.
        // Only pick up concrete type constants like questionType, sectionType.
        if (varName == 'keyType') continue;
        if (!varName.endsWith('Type')) continue;
        final init = variable.initializer;
        if (init is StringLiteral) {
          final jsonKey = _discriminatorJsonKey(varName);
          result[jsonKey] = init.stringValue ?? '';
        }
      }
    }
  }

  return result;
}

/// Maps a Dart constant name like `questionType` to its JSON field name.
String _discriminatorJsonKey(String constantName) {
  const knownMappings = <String, String>{
    'questionType': 'type',
    'sectionType': 'type',
    'expressionType': 'type',
    'taskType': 'type',
    'studyResultType': 'type',
    'observationType': 'type',
  };
  return knownMappings[constantName] ?? 'type';
}
