import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/section.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/section_type.dart';
import 'package:studyu_designer_v2/features/forms/form_control.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:uuid/uuid.dart';

class ReportSectionFormViewModel extends ManagedFormViewModel<ReportSectionFormData>
    implements IListActionProvider<FormControl<dynamic>> {
  static const defaultSectionType = ReportSectionType.average;

  ReportSectionFormViewModel({
    super.formData,
    super.delegate,
    //super.validationSet = StudyFormValidationSet.draft,
  });

  // - Form fields (any section type)

  String get sectionId => sectionIdControl.value!;

  // todo remove sectionId?
  final FormControl<SectionID> sectionIdControl = FormControl(value: const Uuid().v4()); // hidden
  late final FormControl<ReportSectionType> sectionTypeControl = CustomFormControl(
    value: defaultSectionType,
    onValueChanged: onQuestionTypeChanged,
  );
  final FormControl<String> titleControl = FormControl();
  final FormControl<String> descriptionControl = FormControl();
  final FormControl<String> dataSourceControl = FormControl();

  ReportSectionType get sectionType => sectionTypeControl.value ?? defaultSectionType;

  static List<FormControlOption<ReportSectionType>> get sectionTypeControlOptions =>
      ReportSectionType.values.map((e) => FormControlOption(e, e.string))
      .toList();
      /*QuestionFormData.questionTypeFormDataFactories.keys
          .map((questionType) => FormControlOption(questionType, questionType.string))
          .toList();*/

  late final Map<String, AbstractControl> sectionBaseControls = {
    'sectionId': sectionIdControl, // hidden
    'sectionType': sectionTypeControl,
    /*'questionText': questionTextControl,
    'questionInfoText': questionInfoTextControl,*/
  };

  // - Form fields (section type-specific)

  FormArray get answerOptionsArray => {
    ReportSectionType.average: boolResponseOptionsArray,
    ReportSectionType.linearRegression: boolResponseOptionsArray,
  }[sectionType]!;

  List<AbstractControl> get answerOptionsControls => answerOptionsArray.controls;

  final FormControl<TemporalAggregation> averageAggregrationControl = FormControl();

  // Yes/no
  late final FormArray<String> boolResponseOptionsArray = FormArray([]);

  @override
  ReportSectionFormData buildFormData() {
    return ReportSectionFormData(
        isPrimary: false,
        //section: formData!.section
        section: AverageSection.withId(),
    );
  }

  @override
  ManagedFormViewModel<ReportSectionFormData> createDuplicate() {
    return ReportSectionFormViewModel(formData: formData);
  }

  late final Map<ReportSectionType, FormGroup> _controlsBySectionType = {
    ReportSectionType.average: FormGroup({
      'boolOptionsArray': boolResponseOptionsArray,
    }),
    ReportSectionType.linearRegression: FormGroup({
      'boolOptionsArray': boolResponseOptionsArray,
    }),
  };

  @override
  // TODO: implement form
  FormGroup get form => FormGroup({
    ...sectionBaseControls,
    ..._controlsBySectionType[sectionType]!.controls,
  });

  onQuestionTypeChanged(ReportSectionType? sectionType) {
    _updateFormControls(sectionType);
  }

  onResponseOptionsChanged(List<AbstractControl> responseOptionControls) {
    return; // subclass responsibility
  }

  /// Dynamically updates the [form] based on the given [sectionType]
  void _updateFormControls(ReportSectionType? sectionType) {
    final subtypeFormControls = _controlsBySectionType[sectionType]!.controls;
    for (final controlName in form.controls.keys) {
      if (!sectionBaseControls.containsKey(controlName)) {
        form.removeControl(controlName, emitEvent: false);
      }
    }
    form.addAll(subtypeFormControls);
    markFormGroupChanged();
    onResponseOptionsChanged(answerOptionsControls);
  }

  @override
  void setControlsFrom(ReportSectionFormData data) {
    // TODO: implement setControlsFrom
    // Shared Controls
    sectionIdControl.value = data.section.id;
    descriptionControl.value = data.section.description;

    // Type-specific controls
    if (data.section.type == ReportSectionType.average.string) {
    }
  }

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: 'Create',
        FormMode.readonly: 'readonly',
        FormMode.edit: 'edit',
      };

  @override
  List<ModelAction> availableActions(FormControl model) {
    // TODO: implement availableActions
    throw UnimplementedError();
  }

  @override
  void onNewItem() {
    // TODO: implement onNewItem
  }

  @override
  void onSelectItem(FormControl item) {
    // TODO: implement onSelectItem
  }
}
