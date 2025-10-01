import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/simplified_study_converter.dart';

/// Extension on [Study] to provide convenient export functionality.
///
/// This is a designer-specific feature. The conversion logic is contained
/// within the designer_v2 package and is decoupled from the core models.
extension StudyExportExtension on Study {
  /// Converts the [Study] to a simplified, human-readable JSON format
  /// for export.
  ///
  /// The export schema is versioned and designed for portability between
  /// designer instances. It uses a simplified format that differs from
  /// the database JSON serialization.
  ///
  /// Example:
  /// ```dart
  /// final study = Study.withId(userId);
  /// // ... configure study ...
  /// final json = study.toExportSchema();
  /// ```
  ///
  /// To import a study from the export format, use:
  /// ```dart
  /// final study = SimplifiedStudyConverter.fromSchema(json, ownerId: userId);
  /// ```
  Map<String, dynamic> toExportSchema() {
    return SimplifiedStudyConverter.toSchema(this);
  }
}
