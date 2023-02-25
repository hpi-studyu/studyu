import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/section/types/section_type.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';

class ReportSectionFormViewModel extends ManagedFormViewModel<ReportSectionFormData>
    implements IListActionProvider<FormControl<dynamic>> {
  static const defaultQuestionType = ReportSectionType.average;

  ReportSectionFormViewModel({
    super.formData,
    //super.delegate,
    //super.validationSet = StudyFormValidationSet.draft,
  });

  get sectionId => '';

  // - Form fields

  final FormControl<String> titleControl = FormControl();

  @override
  ReportSectionFormData buildFormData() {
    // TODO
    return ReportSectionFormData();
  }

  @override
  ManagedFormViewModel<ReportSectionFormData> createDuplicate() {
    // TODO: implement createDuplicate
    return ReportSectionFormViewModel(formData: formData);
  }

  @override
  // TODO: implement form
  FormGroup get form => FormGroup({});

  @override
  void setControlsFrom(ReportSectionFormData data) {
    // TODO: implement setControlsFrom
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
