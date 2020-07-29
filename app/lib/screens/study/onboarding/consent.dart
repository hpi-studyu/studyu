import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/localization.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import 'onboarding_progress.dart';

class ConsentScreen extends StatefulWidget {
  @override
  _ConsentScreenState createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  StudyInstance study;

  List<bool> boxLogic = List.filled(6, false);
  List<ConsentElement> consentElementList = [
    ConsentElement(
        'Why Consent Is Needed',
        'We need your explicit consent because you are going to enroll to a research study. Therefore, we have to provide you all the information that could potentially have an impact on your decision whether or not you take part in the study. This is study-specific so please go through it carefully. Participation is entirely voluntary.',
        'I agree',
        MdiIcons.featureSearch),
    ConsentElement(
        'Risks & Benefits',
        'The main risks to you if you choose to participate are allergic reactions to one of the interventions you are going to apply. If you feel uncomfortable, suffer from itching or rash please pause the study until you have seen a doctor. It is important to know that you may not get any benefit from taking part in this research. Others may not benefit either. However, study results may help you to understand if one of the offered interventions has a positive effect on one of the investigated observations for you.',
        'I agree',
        MdiIcons.signCaution),
    ConsentElement(
        'Data Handling & Use',
        'By giving your consent you accept that researchers are allowed to process anonymized data collected from you during this study for research purposes. If you stop being in the research study, already transmitted information may not be removed from the research study database because re-identification is not possible. It will continue to be used to complete the research analysis.',
        'I agree',
        MdiIcons.databaseExport),
    ConsentElement(
        'Issues to Consider',
        'For being able to use your results for research we need you to actively participate for the indicated minimum study duration. But since researchers are able to combine your results with results from other participants and therefore need less results from a single participant, for you to receive meaningful results we encourage you to take part at least twice as long. If you decide to take part in this research study you will be responsible for buying the needed aids.',
        'I agree',
        MdiIcons.mapClock),
    ConsentElement(
        'Participant Rights',
        'You may stop taking part in this research study at any time without any penalty. If you have any questions, concerns, or complaints at any time about this research, or you think the research has harmed you, please contact the office of the research team. You can find the contact details in your personal study dashboard.',
        'I agree',
        MdiIcons.gavel),
    ConsentElement(
        'Future Research',
        'The purpose of this research study is to help you find the most effective supporting agent or behavior. The aim is not to treat your symptom causally. In a broader perspective the purpose of this study is also to get insights which group of persons benefits most from which intervention.',
        'I agree',
        MdiIcons.binoculars),
  ];

  void onBoxTapped(int index) {
    setState(() {
      boxLogic[index] = true;
    });
  }

  @override
  void initState() {
    super.initState();
    study = context.read<AppModel>().activeStudy;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(study.title),
        leading: Icon(MdiIcons.fromString(study.iconName)),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  Nof1Localizations.of(context).translate('please_give_consent'),
                  style: theme.textTheme.subtitle1,
                ),
                Flexible(
                  fit: FlexFit.loose,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
                    itemCount: consentElementList.length,
                    itemBuilder: (context, index) {
                      return ConsentCard(
                        consentElement: consentElementList[index],
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
        onNext: () => Navigator.pop(context, true),
        progress: OnboardingProgress(stage: 2, progress: 2.5),
      ),
    );
  }
}

class ConsentCard extends StatelessWidget {
  final ConsentElement consentElement;
  final int index;
  final Function(int) onTapped;
  final bool isChecked;

  const ConsentCard({Key key, this.consentElement, this.index, this.onTapped, this.isChecked}) : super(key: key);

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
              title: Text(consentElement.descriptionText),
            ),
          );
          onTapped(index);
          print('Card tapped.');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(consentElement.title, style: Theme.of(context).textTheme.headline6),
            // Text(consentElement.descriptionText),
            SizedBox(height: 10),
            Icon(consentElement.icon, size: 60),
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
