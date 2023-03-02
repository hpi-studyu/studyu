import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/design/reports/reports_form_data.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/reports/section/report_item_form_data.dart';
import 'package:studyu_designer_v2/features/design/study_form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model_collection_actions.dart';
import 'package:studyu_designer_v2/repositories/api_client.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/model_action.dart';
import 'package:studyu_designer_v2/utils/riverpod.dart';

class ReportsFormViewModel extends FormViewModel<ReportsFormData>
    //with WithQuestionnaireControls<EnrollmentFormData, ScreenerQuestionFormViewModel>
    implements
        IFormViewModelDelegate<ReportSectionFormViewModel>,
        IListActionProvider<ReportSectionFormViewModel>,
        IProviderArgsResolver<ReportSectionFormViewModel, ReportSectionFormRouteArgs> {
  ReportsFormViewModel({
    required this.study,
    required this.router,
    super.delegate,
    super.formData,
    super.autosave = true,
    super.validationSet = StudyFormValidationSet.draft,
  }) {
    // automatically save when a managed child view model is saved
    // propagateOnSave = true;
  }

  final Study study;
  final GoRouter router;

  late final reportSectionDelegate = ReportsFormSectionDelegate(
    formViewModels: reportSectionFormViewModels,
    owner: this,
    validationSet: super.validationSet,
  );

  // - Form fields

  //final FormControl<Participation> enrollmentTypeControl = FormControl();

  /*
    List<FormControlOption<Participation>> get enrollmentTypeControlOptions =>
      Participation.values.map((v) => FormControlOption(v, v.string, description: v.designDescription)).toList();
  */

  final FormArray reportsArray = FormArray([]);
  late final reportSectionFormViewModels = FormViewModelCollection<
      ReportSectionFormViewModel,
      ReportSectionFormData>([], reportsArray);

  List<ReportSectionFormViewModel> get reportSectionModels => reportSectionFormViewModels.formViewModels;

  @override
  FormValidationConfigSet get validationConfig =>
      {
        StudyFormValidationSet.draft: [], // TODO
        StudyFormValidationSet.publish: [], // TODO
        StudyFormValidationSet.test: [], // TODO
      };

  @override
  FormGroup get form =>
      FormGroup({
        'report_specification': reportsArray,
        // ...questionnaireControls,
      });

  @override
  void setControlsFrom(ReportsFormData data) {
    final viewModels = data.reportsFormData.map((data) =>
        ReportSectionFormViewModel(
          formData: data,
          //delegate: reportSectionDelegate,
        )).toList();
    reportSectionFormViewModels.reset(viewModels);
  }

  @override
  ReportsFormData buildFormData() {
    return ReportsFormData(
        reportsFormData: reportSectionFormViewModels.formData
    );
  }

  @override
  Map<FormMode, String> get titles => throw UnimplementedError();

  availablePopupActions(ReportSectionFormViewModel viewModel) {
    final actions = reportSectionFormViewModels.availablePopupActions(viewModel, isReadOnly: isReadonly);
    return withIcons(actions, modelActionIcons);
  }
  ReportSectionFormRouteArgs buildNewResultItemFormRouteArgs() {
    return ReportSectionFormRouteArgs(
      studyId: study.id,
      sectionId: Config.newModelId,
    );
  }

  buildResultItemFormRouteArgs(ReportSectionFormViewModel viewModel) {
    return ReportSectionFormRouteArgs(
      studyId: study.id,
      sectionId: viewModel.sectionId,
    );
  }

  @override
  List<ModelAction> availableActions(ReportSectionFormViewModel model) {
    // TODO: implement availableActions
    throw UnimplementedError();
  }

  @override
  void onCancel(ReportSectionFormViewModel formViewModel, FormMode prevFormMode) {
    // TODO: implement onCancel
  }

  @override
  Future onSave(ReportSectionFormViewModel formViewModel, FormMode prevFormMode) {
    // TODO: implement onSave
    throw UnimplementedError();
  }

  @override
  ReportSectionFormViewModel provide(ReportSectionFormRouteArgs args) {
    if (args.sectionId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      // delegate: null, delegate, reportSectionDelegate, this
      final viewModel = ReportSectionFormViewModel(
        formData: null,
        delegate: reportSectionDelegate,
      );
      reportSectionFormViewModels.stage(viewModel);
      return viewModel;
    }

    final viewModel = reportSectionFormViewModels.findWhere((vm) => vm.sectionId == args.sectionId);
    if (viewModel == null) {
      print("not found1");
      throw ReportSectionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
  }

  @override
  void onSelectItem(ReportSectionFormViewModel item) {
    // TODO: open sidesheet programmatically
  }

  @override
  void onNewItem() {
    // TODO: open sidesheet programmatically
  }
}


class ReportsFormSectionDelegate
    implements
        IFormViewModelDelegate<ReportSectionFormViewModel>,
        IListActionProvider<ReportSectionFormViewModel>,
        IProviderArgsResolver<ReportSectionFormViewModel, ReportSectionFormRouteArgs> {
  ReportsFormSectionDelegate({
    required this.formViewModels,
    required this.owner,
    this.validationSet,
    this.propagateOnSave = true,
  });

  final FormViewModelCollection<ReportSectionFormViewModel, ReportSectionFormData> formViewModels;
  final ReportsFormViewModel owner;
  final bool propagateOnSave;
  final FormValidationSetEnum? validationSet;

  @override
  void onCancel(ReportSectionFormViewModel formViewModel, FormMode prevFormMode) {
    return; // no-op
  }

  @override
  Future onSave(ReportSectionFormViewModel formViewModel, FormMode prevFormMode) async {
    if (prevFormMode == FormMode.create) {
      // Save the managed viewmodel that was eagerly added in [provide]
      formViewModels.commit(formViewModel);
    } else if (prevFormMode == FormMode.edit) {
      // nothing to do here
    }
    if (propagateOnSave) {
      await owner.save();
    }
  }

  @override
  ReportSectionFormViewModel provide(ReportSectionFormRouteArgs args) {
    if (args.sectionId.isNewId) {
      // Eagerly add the managed viewmodel in case it needs to be [provide]d
      // to a child controller
      final viewModel = ReportSectionFormViewModel(
        formData: null,
        delegate: this,
        //validationSet: validationSet,
      );
      formViewModels.stage(viewModel);
      return viewModel;
    }
    final viewModel = formViewModels.findWhere((vm) => vm.sectionId == args.sectionId);
    if (viewModel == null) {
      print("not found");
      throw ReportSectionNotFoundException(); // TODO handle 404 not found
    }
    return viewModel;
    }

  // - IListActionProvider

  @override
  List<ModelAction> availableActions(ReportSectionFormViewModel model) {
    // TODO: implement availableActions
    throw UnimplementedError();
  }

  @override
  void onSelectItem(ReportSectionFormViewModel reportFormViewModel) {
    // TODO: open sidesheet programmatically
  }

  @override
  void onNewItem() {
    // TODO: open sidesheet programmatically
  }
}
