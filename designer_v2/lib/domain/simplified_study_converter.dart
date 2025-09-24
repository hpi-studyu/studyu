import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/domain/study_import.dart';

/// A converter for transforming Study objects to/from simplified schemas.
/// 
/// This class provides a clean interface for exporting studies to LLM-friendly
/// JSON schemas and importing them back into Study objects. The conversion
/// process uses natural language references instead of UUIDs for better
/// LLM compatibility.
class StudyConverter {
  static const schemaVersion = 1;

  StudyConverter._();

  /// Converts a [Study] object to a simplified JSON schema.
  /// 
  /// This method creates a structured representation of the study suitable
  /// for LLM consumption, with natural language references and simplified
  /// data structures.
  /// 
  /// Example:
  /// ```dart
  /// final schema = StudyConverter.toSchema(study);
  /// print(schema['metadata']['title']);
  /// ```
  static Map<String, dynamic> toSchema(Study study) {
    return StudyExport.toSchema(study);
  }

  /// Creates a [Study] object from a simplified JSON schema.
  /// 
  /// This method reconstructs a Study object from the LLM-friendly schema
  /// format, maintaining backward compatibility with native UI-created studies.
  /// 
  /// Parameters:
  /// - [schema]: The JSON schema containing study data
  /// - [ownerId]: The ID of the user who will own this study
  /// 
  /// Returns a fully configured [Study] object ready for use.
  /// 
  /// Example:
  /// ```dart
  /// final study = StudyConverter.fromSchema(
  ///   jsonSchema,
  ///   ownerId: 'user123',
  /// );
  /// ```
  static Study fromSchema(
    Map<String, dynamic> schema, {
    required String ownerId,
  }) {
    return StudyImport.fromSchema(schema, ownerId: ownerId);
  }
}
