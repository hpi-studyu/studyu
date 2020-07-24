import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../util/localization.dart';
import 'onboarding_progress.dart';

class ConsentScreen extends StatefulWidget {
  @override
  _ConsentScreenState createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  List<bool> boxLogic = List.filled(6, false);
  List<ConsentElement> consentElementList = [
    ConsentElement('Box1', 'this', 'I agree'),
    ConsentElement('Box2', 'is', 'I agree'),
    ConsentElement('Box3', 'for', 'I agree'),
    ConsentElement('Box4', 'getting', 'I agree'),
    ConsentElement('Box5', 'your', 'I agree'),
    ConsentElement('Box6', 'data', 'I agree'),
  ];

  void onBoxTapped(int index) {
    setState(() {
      boxLogic[index] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('consent')),
        bottom: OnboardingProgress(stage: 2, progress: 2.5),
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
                  style: theme.textTheme.headline5,
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
                Row(
                  children: [
                    Expanded(
                      child: RaisedButton(
                        onPressed:
                            //boxLogic.every((element) => element == true) ?
                            () {
                          Navigator.pop(context, true);
                        },
                        //  : null,
                        child: Text(Nof1Localizations.of(context).translate('accept')),
                      ),
                    ),
                    Expanded(
                      child: RaisedButton(
                        onPressed:
                            // boxLogic.every((element) => element == true) ?
                            () {
                          Navigator.popUntil(context, ModalRoute.withName(Routes.studySelection));
                        },
                        //   : null,
                        child: Text(Nof1Localizations.of(context).translate('cancel')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
              title: Text('test'),
            ),
          );
          onTapped(index);
          print('Card tapped.');
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(consentElement.title, style: Theme.of(context).textTheme.headline5),
            Text(consentElement.descriptionText),
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

  ConsentElement(this.title, this.descriptionText, this.acknowledgmentText);
}
