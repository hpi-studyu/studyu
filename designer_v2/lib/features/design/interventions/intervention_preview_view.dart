import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/study/study_test_frame.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/routing/router_config.dart';

class InterventionPreview extends ConsumerWidget {
  const InterventionPreview({
    required this.routeArgs,
    Key? key
  }) : super(key: key);

  final InterventionFormRouteArgs routeArgs;

  // todo implement a banner here to show validation errors

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Container(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.25),
        child: Column(
            children: [
              banner(ref) ?? const SizedBox.shrink(),
              const SizedBox(height: 50),
              PreviewFrame(routeArgs.studyId, routeArgs: routeArgs),
            ]
        )
    );
  }

  Widget? banner(WidgetRef ref) {
    final formViewModel = ref.watch(studyTestValidatorProvider(routeArgs.studyId));

    if (!formViewModel.form.hasErrors) {
      return null;
    }
    return BannerBox(
      body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextParagraph(
              text: "The preview is unavailable until you update the "
                  "following information:".hardcoded,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ReactiveForm(
                formGroup: formViewModel.form,
                child: ReactiveFormConsumer(builder: (context, form, child) {
                  return TextParagraph(
                    text: form.validationErrorSummary,
                  );
                })),
          ]),
      style: BannerStyle.warning,
    );
  }
}
