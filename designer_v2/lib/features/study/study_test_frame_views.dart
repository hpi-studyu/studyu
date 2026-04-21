import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

enum PreviewOverlayStage { healthChecking, connecting, appLoading, error, none }

class WebFrame extends StatelessWidget {
  final String previewSrc;
  final String studyId;
  const WebFrame(this.previewSrc, this.studyId, {super.key});

  @override
  Widget build(BuildContext context) {
    // todo make dynamic width should be half the size of height or height double the width
    // final height = MediaQuery.of(context).size.height;
    // final width = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);
    return PhoneContainer(
      innerContent: HtmlElementView(key: key, viewType: '$studyId$key'),
      borderColor: theme.colorScheme.secondary.withValues(alpha: 0.4),
      innerContentBackgroundColor: theme.colorScheme.secondary.withValues(
        alpha: 0.025,
      ),
    );
  }
}

class DisabledFrame extends StatelessWidget {
  const DisabledFrame({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneContainer(
      innerContent: const Center(
        child: Opacity(
          opacity: 0.3,
          child: EmptyBody(
            icon: Icons.visibility_off_rounded,
            title: "",
            description: "",
          ),
        ),
      ),
      borderColor: theme.colorScheme.secondary.withValues(alpha: 0.3),
      innerContentBackgroundColor: theme.colorScheme.secondary.withValues(
        alpha: 0.03,
      ),
    );
  }
}

class PreviewStatusFrame extends StatelessWidget {
  const PreviewStatusFrame({
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.borderColor,
    this.innerContentBackgroundColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? action;
  final Color? borderColor;
  final Color? innerContentBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PhoneContainer(
      innerContent: Padding(
        padding: const EdgeInsets.all(18.0),
        child: EmptyBody(
          icon: icon,
          title: title,
          description: description,
          button: action,
        ),
      ),
      borderColor:
          borderColor ?? theme.colorScheme.secondary.withValues(alpha: 0.35),
      innerContentBackgroundColor:
          innerContentBackgroundColor ??
          theme.colorScheme.secondary.withValues(alpha: 0.08),
    );
  }
}

class LoadingFrame extends StatelessWidget {
  const LoadingFrame({
    required this.configuredUrl,
    required this.isLocalDevelopment,
    required this.stage,
    this.message,
    super.key,
  });

  final String configuredUrl;
  final bool isLocalDevelopment;
  final PreviewOverlayStage stage;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final title = switch (stage) {
      PreviewOverlayStage.healthChecking => 'Checking app availability',
      PreviewOverlayStage.connecting => 'Connecting to app preview',
      PreviewOverlayStage.appLoading => 'Loading app preview',
      PreviewOverlayStage.error || PreviewOverlayStage.none => '',
    };
    final description =
        message ??
        switch (stage) {
          PreviewOverlayStage.healthChecking => isLocalDevelopment
              ? 'Checking whether the StudyU app is running at $configuredUrl.'
              : 'Checking whether the participant app is reachable at $configuredUrl.',
          PreviewOverlayStage.connecting => isLocalDevelopment
              ? 'The local StudyU app is reachable. Establishing the iframe connection now.'
              : 'The participant app is reachable. Establishing the preview connection now.',
          PreviewOverlayStage.appLoading => isLocalDevelopment
              ? 'The app preview is connected. The app is now loading inside the phone frame.'
              : 'The app preview is connected. The participant app is now loading.',
          PreviewOverlayStage.error || PreviewOverlayStage.none => '',
        };

    return PreviewStatusFrame(
      icon: Icons.sync_rounded,
      title: title.hardcoded,
      description: description.hardcoded,
      action: const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
      innerContentBackgroundColor: Colors.white,
    );
  }
}

class ErrorFrame extends StatelessWidget {
  const ErrorFrame({
    required this.title,
    required this.message,
    super.key,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return PreviewStatusFrame(
      icon: Icons.warning_amber_rounded,
      title: title,
      description: message,
      innerContentBackgroundColor: Colors.white,
    );
  }
}

class PhoneContainer extends StatelessWidget {
  static const double defaultWidth = 300.0;
  static const double defaultHeight = 600.0;

  const PhoneContainer({
    required this.innerContent,
    this.width = PhoneContainer.defaultWidth,
    this.height = PhoneContainer.defaultHeight,
    this.borderColor = Colors.black,
    this.borderWidth = 8.0,
    this.borderRadius = 25.0,
    this.innerContentBackgroundColor = Colors.white,
    super.key,
  });

  final double width;
  final double height;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;

  final Widget innerContent;
  final Color? innerContentBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Stack(
        children: <Widget>[
          Stack(
            children: [
              // Not working https://github.com/flutter/flutter/issues/91191
              // Workaround with increased borderWidth
              /* ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: */
              Padding(
                padding: EdgeInsets.all(borderWidth),
                child: Stack(
                  children: [
                    Container(color: innerContentBackgroundColor),
                    innerContent,
                  ],
                ),
              ),
              // ),
              ClipRRect(
                // opaque border so that we can draw on top with other colors
                borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(borderRadius),
                    ),
                    border: Border.all(width: borderWidth, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              border: Border.all(width: borderWidth, color: borderColor),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: SizedBox(height: 600, width: 300));
  }
}

class DesktopFrame extends StatelessWidget {
  const DesktopFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: SizedBox(height: 600, width: 300));
  }
}

Widget? previewBanner(WidgetRef ref, String studyId) {
  final formViewModel = ref.watch(studyTestValidatorProvider(studyId));

  if (!formViewModel.form.hasErrors) {
    return null;
  }
  return BannerBox(
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextParagraph(
          text: tr.banner_study_preview_unavailable,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ReactiveForm(
          formGroup: formViewModel.form,
          child: ReactiveFormConsumer(
            builder: (context, form, child) {
              return TextParagraph(text: form.validationErrorSummary);
            },
          ),
        ),
      ],
    ),
    style: BannerStyle.warning,
  );
}
