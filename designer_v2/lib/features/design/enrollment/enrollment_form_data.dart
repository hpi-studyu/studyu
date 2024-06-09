import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/questionnaire_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_data.dart';

class EnrollmentFormData implements IStudyFormData {
  static const kDefaultEnrollmentType = Participation.invite;

  EnrollmentFormData({
    required this.enrollmentType,
    required this.questionnaireFormData,
    this.consentItemsFormData,
  });

  final Participation enrollmentType;
  final QuestionnaireFormData questionnaireFormData;
  final List<ConsentItemFormData>? consentItemsFormData;

  factory EnrollmentFormData.fromStudy(Study study) {
    return EnrollmentFormData(
      enrollmentType: study.participation,
      questionnaireFormData: QuestionnaireFormData.fromDomainModel(
          study.questionnaire, study.eligibilityCriteria,),
      consentItemsFormData: study.consent
          .map(
              (consentItem) => ConsentItemFormData.fromDomainModel(consentItem),)
          .toList(),
    );
  }

  @override
  Study apply(Study study) {
    study.participation = enrollmentType;
    study.questionnaire = questionnaireFormData.toQuestionnaire();
    study.consent = (consentItemsFormData != null)
        ? consentItemsFormData!
            .map((formData) => formData.toConsentItem())
            .toList()
        : [];
    study.eligibilityCriteria = questionnaireFormData.toEligibilityCriteria();
    return study;
  }

  @override
  String get id =>
      throw UnimplementedError(); // not needed for top-level form data

  @override
  EnrollmentFormData copy() {
    throw UnimplementedError(); // not needed for top-level form data
  }
}
