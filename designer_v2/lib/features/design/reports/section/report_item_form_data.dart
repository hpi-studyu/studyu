import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/forms/form_data.dart';
import 'package:uuid/uuid.dart';
// todo where to use report_section.dart SectionParser?
//typedef ReportSectionFormDataFactory = ReportSectionFormData Function(
//    Question question, List<EligibilityCriterion> eligibilityCriteria);

class ReportSectionFormData extends IFormData {
  //static Map<ReportSectionType, ReportSectionFormDataFactory> questionTypeFormDataFactories = {}

  ReportSectionFormData({
    required this.isPrimary,
    required this.section
  });

  final bool isPrimary;
  final ReportSection section;
  /*final void Function() remove;
  final void Function(ReportSection) updateSection;*/

  //ReportSectionFormData(this.isPrimary, this.section, this.remove, this.updateSection);*/

  get title => '123';

  @override
  // TODO: implement id
  FormDataID get id => const Uuid().v4();

  static fromDomainModel(ReportSpecification reportSpecification) {
    final List<ReportSectionFormData> reportsFormData = [];
    if (reportSpecification.primary != null) {
      reportsFormData.add(ReportSectionFormData(isPrimary: true, section: reportSpecification.primary!));
    }
    for (ReportSection reportSection in reportSpecification.secondary) {
      reportsFormData.add(ReportSectionFormData(isPrimary: false, section: reportSection));
    }
    return reportsFormData;
  }

  @override
  IFormData copy() {
    // TODO: implement copy
    return ReportSectionFormData(isPrimary: isPrimary, section: section);
  }
}

/*class AverageSectionFormData extends ReportSectionFormData {
  AverageSectionFormData({
    required super.isPrimary,
    required super.section
  });

  static Map<String, bool> get kResponseOptions => {
    tr.form_array_response_options_bool_yes: true,
    tr.form_array_response_options_bool_no: false,
  };

  @override
  List<String> get responseOptions => kResponseOptions.keys.toList();

  factory BoolQuestionFormData.fromDomainModel(
      BooleanQuestion question,
      List<EligibilityCriterion> eligibilityCriteria,
      ) {
    final data = BoolQuestionFormData(
      questionId: question.id,
      questionType: SurveyQuestionType.bool,
      questionText: question.prompt ?? '',
      questionInfoText: question.rationale ?? '',
    );
    data.setResponseOptionsValidityFrom(eligibilityCriteria);
    return data;
  }

  @override
  Question toQuestion() {
    final question = BooleanQuestion();
    question.id = questionId;
    question.prompt = questionText;
    question.rationale = questionInfoText;
    return question;
  }

  @override
  BoolQuestionFormData copy() {
    final data = BoolQuestionFormData(
      questionId: const Uuid().v4(), // always regenerate id
      questionType: questionType,
      questionText: questionText.withDuplicateLabel(),
      questionInfoText: questionInfoText,
    );
    data.responseOptionsValidity = responseOptionsValidity;
    return data;
  }

  @override
  Answer constructAnswerFor(responseOption) {
    final question = toQuestion() as BooleanQuestion;
    final value = kResponseOptions[responseOption] as bool;
    return question.constructAnswer(value);
  }
}*/
