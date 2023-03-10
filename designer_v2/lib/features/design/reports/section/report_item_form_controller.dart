import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/section.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/data_reference_identifier.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/section_type.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:uuid/uuid.dart';

class ReportItemFormViewModel extends ManagedFormViewModel<ReportItemFormData> {
  static const defaultSectionType = ReportSectionType.average;
  ReportItemFormViewModel({
    super.formData,
    super.delegate,
    super.validationSet = StudyFormValidationSet.draft,
  });

  // - Form fields (any section type)

  String get sectionId => sectionIdControl.value!;
  final FormControl<SectionID> sectionIdControl = FormControl(value: const Uuid().v4()); // hidden
  late final FormControl<ReportSectionType> sectionTypeControl = CustomFormControl(
    value: defaultSectionType,
    onValueChanged: onQuestionTypeChanged,
  );
  final FormControl<String> titleControl = FormControl();
  final FormControl<String> descriptionControl = FormControl();

  final FormControl<ReportSection> sectionControl = CustomFormControl(value: AverageSection.withId());

  ReportSectionType get sectionType => sectionTypeControl.value ?? defaultSectionType;

  static List<FormControlOption<ReportSectionType>> get sectionTypeControlOptions =>
      ReportSectionType.values.map((e) => FormControlOption(e, e.string)).toList();

  // DataReference might need to be section specific in the future
  final FormControl<DataReferenceIdentifier<num>> dataReferenceControl = FormControl();

  // - Form fields (section type-specific)

  // -- Average
  static List<FormControlOption<TemporalAggregation>> get temporalAggregationControlOptions =>
      TemporalAggregation.values.map((e) => FormControlOption(e, e.string)).toList();
  final FormControl<TemporalAggregation> temporalAggregationControl = FormControl();

  // -- LinearRegression
  static List<FormControlOption<ImprovementDirection>> get improvementDirectionControlOptions =>
      ImprovementDirection.values.map((e) => FormControlOption(e, e.string)).toList();
  final FormControl<ImprovementDirection> improvementDirectionControl = FormControl();
  final FormControl<double> alphaControl = FormControl(); // todo must be numeric (double)


  @override
  Map<FormMode, String> get titles => {
    FormMode.create: tr.form_report_create,
    FormMode.edit: tr.form_report_edit,
    FormMode.readonly: tr.form_report_readonly,
  };

  @override
  FormValidationConfigSet get validationConfig => {
    StudyFormValidationSet.draft: [titleRequired, descriptionRequired],
    StudyFormValidationSet.publish: [titleRequired, descriptionRequired],
    StudyFormValidationSet.test: [titleRequired, descriptionRequired],
  };

  get titleRequired => FormControlValidation(control: titleControl, validators: [
    Validators.required
  ], validationMessages: {
    ValidationMessage.required: (error) => tr.form_field_consent_title_required,
  });
  get descriptionRequired => FormControlValidation(control: descriptionControl, validators: [
    Validators.required
  ], validationMessages: {
    ValidationMessage.required: (error) => tr.form_field_consent_text_required,
  });

  late final Map<String, AbstractControl> sectionBaseControls = {
    'sectionId': sectionIdControl, // hidden
    'section': sectionControl,
    'sectionType': sectionTypeControl,
    'descriptionControl': descriptionControl,
    'titleControl': titleControl,
  };

  @override
  ReportItemFormData buildFormData() {
    buildSectionSpecific(ReportSectionType sectionType) {
      switch(sectionType) {
        case ReportSectionType.average:
          AverageSection averageSection = AverageSection();
          averageSection.aggregate = temporalAggregationControl.value!;
          averageSection.resultProperty = dataReferenceControl.value!;
          return averageSection;
        case ReportSectionType.linearRegression:
          LinearRegressionSection linearSection = LinearRegressionSection();
          linearSection.improvement = improvementDirectionControl.value;
          linearSection.alpha = alphaControl.value!;
          linearSection.resultProperty = dataReferenceControl.value!;
          return linearSection;
      }
    }
    final sectionType = sectionTypeControl.value!;
    ReportSection section = buildSectionSpecific(sectionType);

    section.id = sectionId;
    section.title = titleControl.value!;
    section.description = descriptionControl.value!;

    bool primaryStatus = false;
    if (formData != null) {
      primaryStatus = formData!.isPrimary;
    }
    return ReportItemFormData(
      isPrimary: primaryStatus,
      section: section,
    );
  }

  // - ManagedFormViewModel
  @override
  ReportItemFormViewModel createDuplicate() {
    return ReportItemFormViewModel(
      formData: formData?.copy(),
      delegate: delegate,
      validationSet: validationSet,
    );
  }

  @override
  late final FormGroup form = FormGroup({
    ...sectionBaseControls,
  });

  onQuestionTypeChanged(ReportSectionType? sectionType) {
    _updateFormControls(sectionType);
  }

  onResponseOptionsChanged(List<AbstractControl> responseOptionControls) {
    return; // subclass responsibility
  }

  /// Dynamically updates the [form] based on the given [sectionType]
  void _updateFormControls(ReportSectionType? sectionType) {
    markFormGroupChanged();
  }

  @override
  void setControlsFrom(ReportItemFormData data) {
    final sectionType = ReportSectionType.of(data.section);
    // Shared Controls
    sectionIdControl.value = data.section.id;
    sectionTypeControl.value = sectionType;
    sectionControl.value = data.section;

    titleControl.value = data.section.title;
    descriptionControl.value = data.section.description;

    // Type-specific controls
    switch(sectionType) {
      case ReportSectionType.average:
        AverageSection averageSection = data.section as AverageSection;
        temporalAggregationControl.value = averageSection.aggregate;
        dataReferenceControl.value = DataReferenceIdentifier(
            averageSection.resultProperty!.task,
            averageSection.resultProperty!.property
        );
        break;
      case ReportSectionType.linearRegression:
        LinearRegressionSection linearRegressionSection = data.section as LinearRegressionSection;
        improvementDirectionControl.value = linearRegressionSection.improvement;
        alphaControl.value = linearRegressionSection.alpha;
        dataReferenceControl.value = DataReferenceIdentifier(
            linearRegressionSection.resultProperty!.task,
            linearRegressionSection.resultProperty!.property
        );
        break;
    }
  }
}
