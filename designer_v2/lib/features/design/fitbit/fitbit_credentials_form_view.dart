import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/form_table_layout.dart';
import 'package:studyu_designer_v2/common_views/text_paragraph.dart';
import 'package:studyu_designer_v2/features/design/study_design_page_view.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
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
        final formViewModel =
            ref.watch(fitbitCredentialsFormViewModelProvider(studyId));

        return ReactiveForm(
          formGroup: formViewModel.form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextParagraph(
                text:
                    'To integrate Fitbit data, follow these steps to obtain your Client ID and Client Secret:',
              ),
              const SizedBox(height: 12.0),
              InkWell(
                onTap: () => _launchURL('https://dev.fitbit.com/'),
                child: Text(
                  '1. Go to the Fitbit Developer Portal.',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              InkWell(
                  onTap: () => _launchURL('https://accounts.fitbit.com/login'),
                  child: Text(
                    '2. Log in with your Fitbit account or create one if you do not have it.',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),),
              TextParagraph(
                  text:
                      '3. Navigate to the "Manage" section and select "Register an App".',),
              TextParagraph(
                text:
                    '4. Fill in the required fields such as application name, description, and callback URL (use: "https://example.com/callback").',
              ),
              TextParagraph(
                  text:
                      '5. Select "Client" under "OAuth 2.0 Application Type" and set "Access" to "Read-Only."',),
              TextParagraph(
                  text:
                      '6. Submit the form to get your "Client ID" and "Client Secret".',),
              TextParagraph(text: '7. Copy and paste the credentials below.'),
              const SizedBox(height: 12.0),
              _buildScreenshotsSection(context),
              const SizedBox(height: 16.0),
              TextParagraph(
                text:
                    'Once you enter the credentials, Fitbit integration will be enabled for your study.',
              ),
              const SizedBox(height: 12.0),
              TextParagraph(
                text:
                    'To add a Fitbit question, navigate to the measurements section and create a new Fitbit Question within a measurement.',
              ),
              const SizedBox(height: 24.0),
              FormTableLayout(
                rows: [
                  FormTableRow(
                    control: formViewModel.clientIdControl,
                    label: 'Client ID',
                    labelHelpText:
                        'Enter the Client ID from Fitbit Developer Portal.',
                    input: Row(
                      children: [
                        Expanded(
                          child: ReactiveTextField(
                            formControl: formViewModel.clientIdControl,
                            decoration: const InputDecoration(
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
                    labelHelpText:
                        'Enter the Client Secret from Fitbit Developer Portal.',
                    input: ReactiveTextField(
                      formControl: formViewModel.clientSecretControl,
                      decoration: const InputDecoration(
                        hintText: 'Client Secret',
                      ),
                    ),
                  ),
                ],
                columnWidths: const {
                  0: FlexColumnWidth(),
                },
              ),
            ],
          ),
        );
      },
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
        const Text(
          'Screenshots for Guidance:',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
                  _buildScreenshot(context, 'assets/images/step1.png',
                      'Step 1: Developer Portal',),
                  _buildScreenshot(
                      context, 'assets/images/step2.png', 'Step 2: Login',),
                  _buildScreenshot(context, 'assets/images/step3.png',
                      'Step 3: Register App',),
                  _buildScreenshot(context, 'assets/images/step4.png',
                      'Step 4: Input Details',),
                  _buildScreenshot(
                      context, 'assets/images/step5.png', 'Step 5: Set Access',),
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
      BuildContext context, String imagePath, String caption,) {
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
            Text(
              caption,
              style: const TextStyle(fontSize: 12.0),
            ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(
      BuildContext context, String imagePath, String caption,) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black87,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
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
