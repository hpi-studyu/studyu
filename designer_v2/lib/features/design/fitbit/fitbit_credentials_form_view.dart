import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/fitbit/fitbit_credentials_form_controller.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:url_launcher/url_launcher.dart';

class StudyDesignFitbitCredentialsFormView extends StudyDesignPageWidget {
  const StudyDesignFitbitCredentialsFormView(super.studyId, {super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(studyControllerProvider(studyId));

    return AsyncValueWidget(
      value: state.study,
      data: (study) {
        final formViewModel = ref.watch(
          fitbitCredentialsFormViewModelProvider(studyId),
        );

        if (!study.isDraft) {
          return Padding(
            padding: const EdgeInsets.only(top: 24),
            child: EmptyBody(
              icon: Icons.block_sharp,
              title: tr.fitbit_credentials_cannot_change_title,
              description: tr.fitbit_credentials_cannot_change_description,
            ),
          );
        }

        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                text: AppLocalizations.of(
                  context,
                )!.fitbit_credentials_instruction,
              ),
              const SizedBox(height: 12.0),
              InkWell(
                onTap: () => _launchURL('https://dev.fitbit.com/'),
                child: Text(
                  AppLocalizations.of(context)!.fitbit_credentials_step1,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _launchURL('https://accounts.fitbit.com/login'),
                child: Text(
                  AppLocalizations.of(context)!.fitbit_credentials_step2,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextParagraph(
                text: AppLocalizations.of(context)!.fitbit_credentials_step3,
              ),
              TextParagraph(
                text: AppLocalizations.of(context)!.fitbit_credentials_step4,
              ),
              TextParagraph(
                text: AppLocalizations.of(context)!.fitbit_credentials_step5,
              ),
              TextParagraph(
                text: AppLocalizations.of(context)!.fitbit_credentials_step6,
              ),
              InkWell(
                onTap: () => _launchURL(
                  'https://partners.fitbit.com/researchapplication',
                ),
                child: Text(
                  AppLocalizations.of(context)!.fitbit_credentials_step7,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextParagraph(
                text: AppLocalizations.of(context)!.fitbit_credentials_step8,
              ),
              const SizedBox(height: 12.0),
              _buildScreenshotsSection(context),
              const SizedBox(height: 16.0),
              _buildSingleParticipantInstructions(context),
              const SizedBox(height: 24.0),
              FormTableLayout(
                rows: [
                  FormTableRow(
                    control: formViewModel.clientIdControl,
                    label: AppLocalizations.of(context)!.client_id,
                    labelHelpText: AppLocalizations.of(
                      context,
                    )!.client_id_label_help,
                    input: Row(
                      children: [
                        Expanded(
                          child: ReactiveTextField(
                            formControl: formViewModel.clientIdControl,
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(
                                context,
                              )!.client_id_hint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  FormTableRow(
                    control: formViewModel.clientSecretControl,
                    label: AppLocalizations.of(context)!.client_secret,
                    labelHelpText: AppLocalizations.of(
                      context,
                    )!.client_secret_label_help,
                    input: ReactiveTextField(
                      formControl: formViewModel.clientSecretControl,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.client_secret_hint,
                      ),
                    ),
                  ),
                ],
                columnWidths: const {0: FlexColumnWidth()},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSingleParticipantInstructions(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text(
                  AppLocalizations.of(context)!.fitbit_only_participant_title,
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              AppLocalizations.of(context)!.fitbit_only_participant_subtitle,
              style: const TextStyle(fontSize: 14.0),
            ),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.fitbit_only_participant_step_1,
                ),
                const SizedBox(height: 4.0),
                Text(
                  AppLocalizations.of(context)!.fitbit_only_participant_step_2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotsSection(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    void scrollLeft() {
      scrollController.animateTo(
        scrollController.offset - 200.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    void scrollRight() {
      scrollController.animateTo(
        scrollController.offset + 200.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16.0),
        Text(
          AppLocalizations.of(context)!.screenshots_for_guidance,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12.0),
        Stack(
          children: [
            SizedBox(
              height: 200.0,
              child: ListView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                children: [
                  _buildScreenshot(
                    context,
                    'assets/images/step1.png',
                    AppLocalizations.of(
                      context,
                    )!.fitbit_credentials_screenshot_step1,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step2.png',
                    AppLocalizations.of(
                      context,
                    )!.fitbit_credentials_screenshot_step2,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step3.png',
                    AppLocalizations.of(
                      context,
                    )!.fitbit_credentials_screenshot_step3,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step4.png',
                    AppLocalizations.of(
                      context,
                    )!.fitbit_credentials_screenshot_step4,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step5.png',
                    AppLocalizations.of(
                      context,
                    )!.fitbit_credentials_screenshot_step5,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step6.png',
                    AppLocalizations.of(
                      context,
                    )!.fitbit_credentials_screenshot_step6,
                  ),
                  _buildScreenshot(
                    context,
                    'assets/images/step7.png',
                    AppLocalizations.of(
                      context,
                    )!.fitbit_credentials_screenshot_step7,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.arrow_left, size: 32.0),
                  onPressed: scrollLeft,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Container(
                alignment: Alignment.center,
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.arrow_right, size: 32.0),
                  onPressed: scrollRight,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScreenshot(
    BuildContext context,
    String imagePath,
    String caption,
  ) {
    return GestureDetector(
      onTap: () => _showImageDialog(context, imagePath, caption),
      child: Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: 200.0,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(caption, style: const TextStyle(fontSize: 12.0)),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(
    BuildContext context,
    String imagePath,
    String caption,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagePath, fit: BoxFit.contain),
            const SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                caption,
                style: const TextStyle(fontSize: 14.0, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
