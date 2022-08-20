import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_control_label.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/under_construction.dart';
import 'package:studyu_designer_v2/features/analyze/study_analyze_controller.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/theme.dart';

class StudyAnalyzeScreen extends StudyPageWidget {
  const StudyAnalyzeScreen(studyId, {Key? key}) : super(studyId, key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final controller =
        ref.watch(studyAnalyzeControllerProvider(studyId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: ThemeConfig.containerColor(theme),
          width: double.infinity,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 18.0, horizontal: 48.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SelectableText("Want to run your own analysis?".hardcoded),
                const SizedBox(width: 48.0),
                PrimaryButton(
                  text: "Export as".hardcoded,
                  icon: Icons.download_rounded,
                  onPressedFuture: () => controller.onExport(),
                ),
                const SizedBox(width: 12.0),
                Wrap(
                    children: controller.fileTypeControlOptions
                        .map(
                          (option) => IntrinsicWidth(
                        child: Row(
                          children: [
                            ReactiveRadio<FileType>(
                              formControl: controller.fileTypeControl,
                              value: option.value,
                            ),
                            const SizedBox(width: 2.0),
                            FormControlLabel(
                              formControl: controller.fileTypeControl,
                              text: option.label,
                              onClick: (formControl) =>
                              formControl.value = option.value,
                            ),
                            const SizedBox(width: 8.0),
                          ],
                        ),
                      ),
                    )
                        .toList()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32.0),
        SelectableText("Outcome measures by intervention".hardcoded,
            style: Theme.of(context).textTheme.headline5),
        const SizedBox(height: 32.0),
        Container(
          width: 800,
          color: theme.colorScheme.secondary.withOpacity(0.03),
          height: 300,
          child: const Center(
            child: UnderConstruction(),
          )
        )
      ],
    );
  }
}
