import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';
import '../../../util/save_pdf.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import 'onboarding_progress.dart';

class ConsentScreen extends StatefulWidget {
  @override
  _ConsentScreenState createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  ParseUserStudy study;
  List<bool> boxLogic;
  List<ConsentItem> consentList;

  void onBoxTapped(int index) {
    setState(() {
      boxLogic[index] = true;
    });
  }

  @override
  void initState() {
    super.initState();
    study = context.read<AppState>().activeStudy;
    consentList = study.consent;
    boxLogic = List.filled(consentList.length, false);
  }

  Future<List<pw.Widget>> generatePdfContent() async {
    final ttf = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));
    return consentList
        .map((consentItem) => [
              pw.Header(
                level: 0,
                child: pw.Text(consentItem.title ?? '', textScaleFactor: 2, style: pw.TextStyle(font: ttf)),
              ),
              pw.Paragraph(text: consentItem.description ?? '', style: pw.TextStyle(font: ttf)),
            ])
        .expand((element) => element)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('consent')),
        leading: Icon(MdiIcons.fromString(study.iconName)),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async => savePDF(context, '${study.title}_consent', await generatePdfContent()),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: Nof1Localizations.of(context).translate('please_give_consent'),
                      style: theme.textTheme.subtitle1,
                    ),
                    TextSpan(
                      text: ' ',
                      style: theme.textTheme.subtitle1,
                    ),
                    TextSpan(
                      text: Nof1Localizations.of(context).translate('please_give_consent_why'),
                      style: theme.textTheme.subtitle2.copyWith(color: theme.primaryColor),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: Text(Nof1Localizations.of(context).translate('please_give_consent_reason')),
                              ),
                            ),
                    )
                  ]),
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
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
        backLabel: Nof1Localizations.of(context).translate('decline'),
        backIcon: Icon(Icons.close),
        onBack: () => Navigator.popUntil(context, ModalRoute.withName(Routes.studySelection)),
        nextLabel: Nof1Localizations.of(context).translate('accept'),
        nextIcon: Icon(Icons.check),
        onNext: boxLogic.every((element) => element) ? () => Navigator.pop(context, true) : null,
        progress: OnboardingProgress(stage: 2, progress: 2.5),
      ),
    );
  }
}

class ConsentCard extends StatelessWidget {
  final ConsentItem consent;
  final int index;
  final Function(int) onTapped;
  final bool isChecked;

  const ConsentCard({Key key, this.consent, this.index, this.onTapped, this.isChecked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isChecked ? Colors.blue[100] : Colors.grey[300],
      child: InkWell(
        splashColor: Colors.orange.withAlpha(100),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(consent.description),
            ),
          );
          onTapped(index);
          print('Card tapped.');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(consent.title, style: Theme.of(context).textTheme.headline6),
            SizedBox(height: 10),
            Icon(MdiIcons.fromString(consent.iconName), size: 60),
          ],
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
