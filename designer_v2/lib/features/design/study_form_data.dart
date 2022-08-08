import 'package:studyu_core/core.dart';

abstract class IStudyFormData {
  factory IStudyFormData.fromStudy(Study study) {
    throw UnimplementedError("Subclass responsibility");
  }

  /// Applies the data stored in [IStudyFormData] to the given [study]
  /// by mapping the form's schema to the [Study] schema
  Study apply(Study study);
}
