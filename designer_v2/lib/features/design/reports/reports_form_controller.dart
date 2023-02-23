import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';

class ReportsFormViewModel extends FormViewModel<ReportsFormData> {
  ReportsFormViewModel({
    required this.study,
    required this.router,
    super.delegate,
    super.formData,
    super.autosave = true,
    super.validationSet = StudyFormValidationSet.draft,
  });

  final Study study;
  final GoRouter router;

  @override
  ReportsFormData buildFormData() {
    // TODO: implement buildFormData
    throw UnimplementedError();
  }

  @override
  // TODO: implement form
  FormGroup get form => throw UnimplementedError();

  @override
  void setControlsFrom(ReportsFormData data) {
    // TODO: implement setControlsFrom
  }

  @override
  // TODO: implement titles
  Map<FormMode, String> get titles => throw UnimplementedError();

}
