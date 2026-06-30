import 'package:studyu_core/src/models/tables/study.dart';
import 'package:studyu_core/src/validators/validation_result.dart';

ValidationResult validateConsent(Study study, ValidationLevel level) {
  final errors = <ValidationError>[];

  // Fact 21 — at least one consent item required for publishing
  if (level == ValidationLevel.publish && study.consent.isEmpty) {
    errors.add(const ValidationError(
      code: 'consent.no_items',
      path: r'$.consent',
      message: 'At least one consent item is required for publishing',
      fixHint:
          'Add a consent item in the Enrollment section of the Designer.',
    ));
  }

  for (var i = 0; i < study.consent.length; i++) {
    final item = study.consent[i];

    // Fact 22
    if (item.title == null || item.title!.trim().isEmpty) {
      errors.add(ValidationError(
        code: 'consent.item_title_required',
        path: r'$.consent[' + i.toString() + r'].title',
        message: 'Consent item at index $i has no title',
        fixHint: 'Set a non-empty title for the consent item.',
      ));
    }

    // Fact 23
    if (item.description == null || item.description!.trim().isEmpty) {
      errors.add(ValidationError(
        code: 'consent.item_description_required',
        path: r'$.consent[' + i.toString() + r'].description',
        message: 'Consent item at index $i has no description',
        fixHint: 'Set a non-empty description for the consent item.',
      ));
    }
  }

  return ValidationResult(errors: errors, warnings: []);
}
