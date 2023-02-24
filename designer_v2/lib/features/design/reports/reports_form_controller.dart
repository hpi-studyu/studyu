import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/features/design/reports/report/report_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/report/report_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_data.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class ReportsFormViewModel extends FormViewModel<ReportsFormData>
    implements IProviderArgsResolver<ReportItemFormViewModel, ReportItemFormRouteArgs> {
  ReportsFormViewModel({
    required this.study,
    required this.router,
    super.delegate,
    super.formData,
    super.autosave = true,
  });

  final Study study;
  final GoRouter router;

  // - Form fields

  final FormControl<ReportSpecification> reportTypeControl = FormControl();

  final FormArray reportsArray = FormArray([]);
  late final reportsCollection = FormViewModelCollection<ReportItemFormViewModel, ReportItemFormData>([], reportsArray);

  @override
  FormGroup get form => FormGroup({'report_specification': reportsArray});

  void onSelectItem(ReportItemFormViewModel reportFormViewModel) {
    // TODO: open sidesheet programmatically
  }

  void onNewItem() {
    // TODO: open sidesheet programmatically
  }

  @override
  ReportsFormData buildFormData() {
    return ReportsFormData(
      reportSpecification: reportTypeControl.value!,
      reportsFormData: reportsCollection.formData,
    );
  }

  @override
  void setControlsFrom(ReportsFormData data) {
    // TODO: implement setControlsFrom
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError();

  availablePopupActions(ReportItemFormViewModel viewModel) {}

  buildReportItemFormRouteArgs(ReportItemFormViewModel model) {
    return ReportItemFormRouteArgs(
      studyId: study.id,
      sectionId: model.sectionId,
    );
  }

  @override
  ReportItemFormViewModel provide(ReportItemFormRouteArgs args) {
    final viewModel = ReportItemFormViewModel(
      formData: null,
    );
    reportsCollection.stage(viewModel);
    return viewModel;
  }

  ReportItemFormRouteArgs buildNewResultItemFormRouteArgs() {
    return ReportItemFormRouteArgs(studyId: study.id, sectionId: '');
  }

  ReportItemFormRouteArgs buildResultItemFormRouteArgs(ReportItemFormViewModel viewModel) {
    return ReportItemFormRouteArgs(studyId: study.id, sectionId: '');
  }
}
