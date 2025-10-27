import 'package:studyu_designer_v2/domain/serialization/utils/export_import_registry.dart';

abstract class ExpressionConversionStrategy {
  Map<String, dynamic> convert(
    Map<String, dynamic> expression,
    ExportImportRegistry registry,
  );
}

class ToHandlesStrategy implements ExpressionConversionStrategy {
  @override
  Map<String, dynamic> convert(
    Map<String, dynamic> expression,
    ExportImportRegistry registry,
  ) {
    final result = Map<String, dynamic>.from(expression);
    final type = result['type'] as String?;

    if (result.containsKey('target')) {
      final targetId = _asString(result['target']);
      final handle = registry.questionIdToHandle[targetId];
      if (handle != null) {
        result['target'] = handle;
      }
    }

    if (type == 'choice') {
      final choices = result['choices'];
      if (choices is List) {
        result['choices'] = choices
            .map(
              (choiceId) =>
                  registry.choiceIdToHandle[_asString(choiceId)] ?? choiceId,
            )
            .toList();
      }
    } else if (type == 'composite') {
      final expressions = result['expressions'];
      if (expressions is List) {
        result['expressions'] = expressions
            .map(
              (entry) => convert(
                Map<String, dynamic>.from(entry as Map),
                registry,
              ),
            )
            .toList();
      }
    } else if (type == 'not') {
      final nested = result['expression'];
      if (nested is Map) {
        result['expression'] = convert(
          Map<String, dynamic>.from(nested),
          registry,
        );
      }
    }

    return result;
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}

class ToIdsStrategy implements ExpressionConversionStrategy {
  @override
  Map<String, dynamic> convert(
    Map<String, dynamic> expression,
    ExportImportRegistry registry,
  ) {
    final result = Map<String, dynamic>.from(expression);
    final type = result['type'] as String?;

    if (result.containsKey('target')) {
      final handle = _asString(result['target']);
      final mappedId = registry.questionHandleToId[handle];
      if (mappedId == null) {
        throw FormatException('Unknown question handle "$handle"');
      }
      result['target'] = mappedId;
    }

    if (type == 'choice') {
      final choices = result['choices'];
      if (choices is List) {
        result['choices'] = choices.map((choiceHandle) {
          if (choiceHandle is String) {
            final mappedId = registry.choiceHandleToId[choiceHandle];
            if (mappedId == null) {
              throw FormatException('Unknown choice handle "$choiceHandle"');
            }
            return mappedId;
          }
          return choiceHandle;
        }).toList();
      }
    } else if (type == 'composite') {
      final expressions = result['expressions'];
      if (expressions is List) {
        result['expressions'] = expressions
            .map(
              (entry) => convert(
                Map<String, dynamic>.from(entry as Map),
                registry,
              ),
            )
            .toList();
      }
    } else if (type == 'not') {
      final nested = result['expression'];
      if (nested is Map) {
        result['expression'] = convert(
          Map<String, dynamic>.from(nested),
          registry,
        );
      }
    }

    return result;
  }

  String _asString(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}

class ExpressionConverter {
  ExpressionConverter._();

  static Map<String, dynamic> toHandles(
    Map<String, dynamic> expression,
    ExportImportRegistry registry,
  ) {
    return ToHandlesStrategy().convert(expression, registry);
  }

  static Map<String, dynamic> toIds(
    Map<String, dynamic> expression,
    ExportImportRegistry registry,
  ) {
    return ToIdsStrategy().convert(expression, registry);
  }
}
