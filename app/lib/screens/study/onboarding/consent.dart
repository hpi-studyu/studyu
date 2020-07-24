import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../routes.dart';
import '../../../util/localization.dart';

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
      ),
      body: PageView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 40),
                Text(
                  Nof1Localizations.of(context).translate('please_give_consent'),
                  style: theme.textTheme.headline5,
                ),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.blue,
                        size: 60,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Stack(
            children: [
              GridView.builder(
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
              Align(
                alignment: FractionalOffset.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.blue,
                    size: 60,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Nof1Localizations.of(context).translate('please_give_consent'),
                  style: theme.textTheme.headline5,
                ),
                SizedBox(height: 40),
                RaisedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(Nof1Localizations.of(context).translate('accept')),
                ),
                RaisedButton(
                  onPressed:
                      // boxLogic.every((element) => element == true) ?
                      () {
                    Navigator.popUntil(context, ModalRoute.withName(Routes.studySelection));
                  },
                  //   : null,
                  child: Text(Nof1Localizations.of(context).translate('cancel')),
                ),
              ],
            ),
          ),
        ],
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
