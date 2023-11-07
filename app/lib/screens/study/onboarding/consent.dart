import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:studyu_app/widgets/html_text.dart';
import 'package:studyu_core/core.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/save_pdf.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import 'onboarding_progress.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  StudySubject? subject;
  late List<bool> boxLogic;
  late List<ConsentItem> consentList;

  void onBoxTapped(int index) {
    setState(() {
      boxLogic[index] = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // todo fix subject is null if page gets reloaded in all files (same solution as in dashboard)
    subject = context.read<AppState>().activeSubject;
    consentList = subject!.study.consent;
    boxLogic = List.filled(consentList.length, false);
  }

  Future<List<pw.Widget>> generatePdfContent() async {
    final ttf = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    return consentList
        .map(
          (consentItem) => [
            pw.Header(
              level: 0,
              child: pw.Text(consentItem.title ?? '', textScaleFactor: 2, style: pw.TextStyle(font: ttf)),
            ),
            pw.Paragraph(text: consentItem.description ?? '', style: pw.TextStyle(font: ttf)),
          ],
        )
        .expand((element) => element)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.consent),
        leading: Icon(MdiIcons.textBoxCheck),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              if (kIsWeb) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    elevation: 24,
                    title: Text(AppLocalizations.of(context)!.save_not_supported),
                    content: Text(AppLocalizations.of(context)!.save_not_supported_description),
                  ),
                );
              }
              final savedFilePath =
                  await savePDF(context, '${subject!.study.title}_consent', await generatePdfContent());
              if (!mounted) return;
              if (savedFilePath != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppLocalizations.of(context)!.was_saved_to}$savedFilePath.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.please_give_consent,
                        style: theme.textTheme.titleMedium,
                      ),
                      TextSpan(
                        text: ' ',
                        style: theme.textTheme.titleMedium,
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context)!.please_give_consent_why,
                        style: theme.textTheme.titleSmall!.copyWith(color: theme.primaryColor),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  content: Text(AppLocalizations.of(context)!.please_give_consent_reason),
                                ),
                              ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: consentList.length,
                    itemBuilder: (context, index) {
                      return ConsentCard(
                        consent: consentList[index],
                        isChecked: boxLogic[index],
                        index: index,
                        onTapped: onBoxTapped,
                      );
                    },
                    primary: false,
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        backLabel: AppLocalizations.of(context)!.decline,
        backIcon: const Icon(Icons.close),
        onBack: () => Navigator.popUntil(context, ModalRoute.withName(Routes.studySelection)),
        nextLabel: AppLocalizations.of(context)!.accept,
        nextIcon: const Icon(Icons.check),
        onNext: boxLogic.every((element) => element) || kDebugMode ? () => Navigator.pop(context, true) : null,
        progress: const OnboardingProgress(stage: 2, progress: 2.5),
      ),
    );
  }
}

class ConsentCard extends StatelessWidget {
  final ConsentItem? consent;
  final int? index;
  final Function(int) onTapped;
  final bool? isChecked;

  const ConsentCard({super.key, this.consent, this.index, required this.onTapped, this.isChecked});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: isChecked! ? Colors.blue[100] : Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.primaryColor,
        ),
      ),
      child: InkWell(
        splashColor: theme.colorScheme.secondary.withAlpha(100),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  consent!.iconName.isNotEmpty
                      ? Icon(MdiIcons.fromString(consent!.iconName), color: theme.primaryColor)
                      : const SizedBox.shrink(),
                  consent!.iconName.isNotEmpty ? const SizedBox(width: 8) : const SizedBox.shrink(),
                  Expanded(child: Text(consent!.title!)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              content: HtmlText(consent!.description),
            ),
          );
          onTapped(index!);
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              consent!.iconName.isNotEmpty
                  ? Icon(MdiIcons.fromString(consent!.iconName), size: 60, color: Colors.blue)
                  : const SizedBox.shrink(),
              consent!.iconName.isNotEmpty ? const SizedBox(height: 10) : const SizedBox.shrink(),
              Flexible(
                child: Text(
                  consent!.title!,
                  style: Theme.of(context).textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConsentElement {
  final String title;
  final String descriptionText;
  final String acknowledgmentText;
  final IconData icon;

  ConsentElement(this.title, this.descriptionText, this.acknowledgmentText, this.icon);
}
