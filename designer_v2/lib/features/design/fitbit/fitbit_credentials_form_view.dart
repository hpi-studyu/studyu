import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';

import '../../../common_views/text_paragraph.dart';
import '../../../localization/app_translation.dart';

class StudyDesignFitbitCredentialsFormView extends StudyDesignPageWidget {
  const StudyDesignFitbitCredentialsFormView(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget(
        value: state.study,
        data: (study) {
          final formViewModel =
              ref.watch(fitbitCredentialsFormViewModelProvider(studyId));

          return ReactiveForm(
              formGroup: formViewModel.form,
              child: Column(children: <Widget>[
                TextParagraph(text: tr.form_study_design_info_description),
                const SizedBox(height: 24.0),
                FormTableLayout(
                  rows: [
                    FormTableRow(
                      control: formViewModel.clientIdControl,
                      label: 'Client ID',
                      labelHelpText: 'Tooltip here',
                      input: Row(
                        children: [
                          Expanded(
                            child: ReactiveTextField(
                              formControl: formViewModel.clientIdControl,
                              decoration: InputDecoration(
                                hintText: 'Client ID',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FormTableRow(
                      control: formViewModel.clientSecretControl,
                      label: 'Client Secret',
                      labelHelpText: 'Tooltip here',
                      input: ReactiveTextField(
                        formControl: formViewModel.clientSecretControl,
                        decoration: InputDecoration(
                          hintText: 'Hint here',
                        ),
                      ),
                    ),
                  ],
                  columnWidths: const {
                    0: FixedColumnWidth(185.0),
                    1: FlexColumnWidth(),
                  },
                ),
              ]));
        });
  }
}
