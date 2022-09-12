import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet_form.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/domain/participation.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/consent_item_form_view.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_form_controller.dart';
import 'package:studyu_designer_v2/features/design/enrollment/screener_question_logic_form_view.dart';
import 'package:studyu_designer_v2/features/design/shared/questionnaire/question/question_form_view.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_array_table.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';
import 'package:studyu_designer_v2/theme.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';

class StudyDesignEnrollmentFormView extends StudyDesignPageWidget {
  const StudyDesignEnrollmentFormView(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget<Study>(
      value: state.study,
      data: (study) {
        final formViewModel =
            ref.read(enrollmentFormViewModelProvider(studyId));
        return ReactiveForm(
          formGroup: formViewModel.form,
          child: ReactiveFormConsumer(
            builder: (context, formGroup, child) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextParagraph(
                    text: "Define who will be able to participate in your study, "
                        "the criteria they have to meet and the terms they have t"
                        "o consent to."
                        .hardcoded),
                const SizedBox(height: 24.0),
                FormTableLayout(
                  rows: [
                    FormTableRow(
                        control: formViewModel.enrollmentTypeControl,
                        label: "Participant pool".hardcoded,
                        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                        input: Column(
                          children: formViewModel.enrollmentTypeControlOptions
                              .map((option) =>
                          ReactiveRadioListTile<Participation>(
                            formControl:
                            formViewModel.enrollmentTypeControl,
                            value: option.value,
                            title: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(option.value.whoShort,
                                    style: theme.textTheme.bodyText1),
                                const SizedBox(height: 2.0),
                              ],
                            ),
                            subtitle: (option.description) != null
                                ? TextParagraph(
                              text: option.description!,
                              selectable: false,
                              style:
                              ThemeConfig.bodyTextMuted(theme),
                            )
                                : null,
                          ) as Widget)
                              .toList()
                              .separatedBy(() => const SizedBox(height: 8.0)),
                        )),
                  ],
                  columnWidths: const {
                    0: FixedColumnWidth(130.0),
                    1: FlexColumnWidth(),
                  },
                ),
                const SizedBox(height: 32.0),
                ReactiveFormArray(
                  formArray: formViewModel.questionsArray,
                  builder: (context, formArray, child) {
                    return FormArrayTable<ScreenerQuestionFormViewModel>(
                      control: formViewModel.questionsArray,
                      items: formViewModel.questionModels,
                      onSelectItem: (viewModel) {
                        final routeArgs = formViewModel
                            .buildScreenerQuestionFormRouteArgs(viewModel);
                        _showScreenerQuestionSidesheetWithArgs(
                            routeArgs, context, ref);
                      },
                      getActionsAt: (viewModel, _) =>
                          formViewModel.availablePopupActions(viewModel),
                      onNewItem: () {
                        final routeArgs =
                        formViewModel.buildNewScreenerQuestionFormRouteArgs();
                        _showScreenerQuestionSidesheetWithArgs(
                            routeArgs, context, ref);
                      },
                      sectionDescription:
                      "Optional screener questions can help determine whether "
                          "a potential participant is qualified to participate "
                          "in the study. For invite-only studies, you may "
                          "choose not to add any screening questions if you are "
                          "manually qualifying & recruiting participants before "
                          "inviting them to StudyU."
                          .hardcoded,
                      onNewItemLabel: 'Add screener question'.hardcoded,
                      rowTitle: (viewModel) =>
                      viewModel.formData?.questionText ??
                          'Missing item title'.hardcoded,
                      leadingWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Screening criteria".hardcoded,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          (formViewModel.canTestScreener)
                              ? Opacity(
                            opacity: ThemeConfig.kMuteFadeFactor,
                            child: TextButton.icon(
                              onPressed: formViewModel.testScreener,
                              icon: const Icon(
                                  Icons.play_circle_outline_rounded),
                              label: Text("Test screener".hardcoded),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      rowPrefix: (context, viewModel, rowIdx) {
                        return Row(
                          children: [
                            Tooltip(
                              message: viewModel.questionType.string,
                              child: Icon(viewModel.questionType.icon,
                                color: ThemeConfig.dropdownMenuItemTheme(theme)
                                    .iconTheme!
                                    .color,
                                size: ThemeConfig.dropdownMenuItemTheme(theme)
                                    .iconTheme!
                                    .size,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24.0),
                ReactiveFormArray(
                  formArray: formViewModel.consentItemArray,
                  builder: (context, formArray, child) {
                    return FormArrayTable<ConsentItemFormViewModel>(
                      control: formViewModel.consentItemArray,
                      items: formViewModel.consentItemModels,
                      onSelectItem: (viewModel) {
                        final routeArgs = formViewModel
                            .buildConsentItemFormRouteArgs(viewModel);
                        _showConsentItemSidesheetWithArgs(
                            routeArgs, context, ref);
                      },
                      getActionsAt: (viewModel, _) => formViewModel
                          .consentItemDelegate
                          .availableActions(viewModel),
                      onNewItem: () {
                        final routeArgs =
                        formViewModel.buildNewConsentItemFormRouteArgs();
                        _showConsentItemSidesheetWithArgs(
                            routeArgs, context, ref);
                      },
                      sectionDescription: "Provide the terms that participants have to "
                          "consent to when enrolling in your study via the "
                          "StudyU app. You may choose not to add any terms here "
                          "if you obtain your participants' consent by some other method"
                          " before recruiting them to your study on StudyU."
                          .hardcoded,
                      onNewItemLabel: 'Add consent text'.hardcoded,
                      rowTitle: (viewModel) =>
                      viewModel.formData?.title ??
                          'Missing item title'.hardcoded,
                      leadingWidget: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Participant consent".hardcoded,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          (formViewModel.canTestConsent)
                              ? Opacity(
                            opacity: ThemeConfig.kMuteFadeFactor,
                            child: TextButton.icon(
                              onPressed: formViewModel.testConsent,
                              icon: const Icon(
                                  Icons.play_circle_outline_rounded),
                              label: Text("Test consent".hardcoded),
                            ),
                          )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  _showScreenerQuestionSidesheetWithArgs(
    ScreenerQuestionFormRouteArgs routeArgs,
    BuildContext context,
    WidgetRef ref,
  ) {
    final formViewModel =
        ref.read(screenerQuestionFormViewModelProvider(routeArgs));

    showFormSideSheet<ScreenerQuestionFormViewModel>(
      context: context,
      formViewModel: formViewModel,
      tabs: <FormSideSheetTab<ScreenerQuestionFormViewModel>>[
        FormSideSheetTab(
          title: "Content".hardcoded,
          index: 0,
          formViewBuilder: (formViewModel) =>
              SurveyQuestionFormView(formViewModel: formViewModel),
        ),
        FormSideSheetTab(
          title: "Logic".hardcoded,
          index: 1,
          formViewBuilder: (formViewModel) =>
              ScreenerQuestionLogicFormView(formViewModel: formViewModel),
        ),
      ],
    );
  }

  // TODO: refactor to use [RoutingIntent] for sidesheet (so that it can be triggered from controller)
  _showConsentItemSidesheetWithArgs(
    ConsentItemFormRouteArgs routeArgs,
    BuildContext context,
    WidgetRef ref,
  ) {
    final formViewModel = ref.read(consentItemFormViewModelProvider(routeArgs));

    showFormSideSheet<ConsentItemFormViewModel>(
      context: context,
      formViewModel: formViewModel,
      formViewBuilder: (formViewModel) =>
          ConsentItemFormView(formViewModel: formViewModel),
    );
  }
}
