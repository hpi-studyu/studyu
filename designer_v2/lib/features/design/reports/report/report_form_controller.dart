import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/design/reports/report/report_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';

class ReportItemFormViewModel extends ManagedFormViewModel<ReportItemFormData> {
  ReportItemFormViewModel({
    super.formData,
    //super.delegate,
    //super.validationSet = StudyFormValidationSet.draft,
  });

  get sectionId => '';

  // - Form fields

  final FormControl<String> titleControl = FormControl();

  @override
  ReportItemFormData buildFormData() {
    // TODO
    return ReportItemFormData();
  }

  @override
  ManagedFormViewModel<ReportItemFormData> createDuplicate() {
    // TODO: implement createDuplicate
    return ReportItemFormViewModel(formData: formData);
  }

  @override
  // TODO: implement form
  FormGroup get form => FormGroup({});

  @override
  void setControlsFrom(ReportItemFormData data) {
    // TODO: implement setControlsFrom
  }

  @override
  Map<FormMode, String> get titles => {
        FormMode.create: 'Create',
        FormMode.readonly: 'readonly',
        FormMode.edit: 'edit',
      };
}
