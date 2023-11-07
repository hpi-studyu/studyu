import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_scaffold.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';

class StudyFormScaffold<T extends FormViewModel> extends ConsumerWidget {
  const StudyFormScaffold(
      {required this.studyId, required this.formViewModelBuilder, required this.formViewBuilder, super.key});

  final StudyID studyId;
  final FormViewModelBuilder<T> formViewModelBuilder;
  final FormViewBuilder<T> formViewBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    // TODO: this architecture results in a 2-stage loading (app init/splash, study)
    // TODO: figure out a way to declare + load data dependencies for routes in one go
    return AsyncValueWidget(
      value: state.study,
      data: (study) {
        final formViewModel = formViewModelBuilder(ref);
        return FormScaffold(
          formViewModel: formViewModel,
          body: formViewBuilder(formViewModel),
        );
        //return formViewBuilder(formViewModel);
      },
    );
  }
}
