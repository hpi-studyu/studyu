import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/converters/converter_context.dart';
import 'package:studyu_designer_v2/domain/converters/study_export_converter.dart';
import 'package:studyu_designer_v2/domain/converters/study_import_converter.dart';

class SimplifiedStudyConverter {
  static const schemaVersion = 1;

  SimplifiedStudyConverter._();

  static Map<String, dynamic> toSchema(Study study) {
    final context = ExportContext();
    return {
      'version': 2,
      'source': 'designer',
      'metadata': StudyExportConverter.exportMetadata(study),
      'studySchedule': StudyExportConverter.exportStudySchedule(study.schedule),
      'screening': StudyExportConverter.exportScreeningForm(study, context),
      'observations': StudyExportConverter.exportObservations(study, context),
      'interventions': StudyExportConverter.exportInterventions(study, context),
      'consent': StudyExportConverter.exportConsent(study),
    };
  }

  static Study fromSchema(
    Map<String, dynamic> schema, {
    required String ownerId,
  }) {
    // Validate platform constraints first
    StudyImportConverter.validatePlatformConstraints(schema);

    final study = Study.withId(ownerId);
    final context = ImportContext();

    // Detect import mode (v1 prompt-based or v2 with IDs)
    context.mode = StudyImportConverter.detectImportMode(schema);

    StudyImportConverter.importMetadata(
      schema['metadata'] as Map<String, dynamic>? ?? {},
      study,
    );

    // Support both 'schedule' (v2) and 'studySchedule' (v1) keys
    final scheduleData =
        schema['schedule'] ?? schema['studySchedule'] as Map<String, dynamic>?;
    StudyImportConverter.importStudySchedule(
      scheduleData as Map<String, dynamic>?,
      study.schedule,
    );

    // Import screening (v1) or eligibility (v2)
    if (schema.containsKey('screening')) {
      StudyImportConverter.importScreeningForm(
        schema['screening'],
        study,
        context,
      );
    } else if (schema.containsKey('eligibility')) {
      // V2 format with top-level eligibility
      StudyImportConverter.importEligibility(
        schema['eligibility'],
        study,
        context,
      );
    }

    StudyImportConverter.importObservations(
      schema['observations'],
      study,
      context,
    );
    StudyImportConverter.importInterventions(schema['interventions'], study);
    StudyImportConverter.importConsent(schema['consent'], study);

    StudyImportConverter.resolveConditionals(study, context);

    return study;
  }
}
