import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../util/localization.dart';
import '../util/user.dart';

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

  List<bool> userCanContinue() {
    return boxLogic;
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
                Text(
                  Nof1Localizations.of(context).translate('please_give_consent'),
                  style: theme.textTheme.headline5,
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            itemCount: consentElementList.length,
            itemBuilder: (context, index) {
              return ConsentCard(
                consentElement: consentElementList[index],
                isChecked: false,
              );
            },
            primary: false,
            padding: const EdgeInsets.all(20),
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
                  onPressed: userCanContinue() != null
                      ? () {
                          UserUtils.getOrCreateUser();
                          Navigator.pushNamed(context, Routes.dashboard);
                        }
                      : null,
                  child: Text(Nof1Localizations.of(context).translate('get_started')),
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
  final Function onChange;
  final bool isChecked;

  const ConsentCard({Key key, this.consentElement, this.onChange, this.isChecked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[100],
      child: InkWell(
        splashColor: Colors.orange.withAlpha(100),
        onTap: () {
          print('Card tapped.');
        },
        child: Container(
          width: 300,
          height: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(consentElement.title, style: Theme
                  .of(context)
                  .textTheme
                  .headline5),
              Text(consentElement.descriptionText),
              Align(alignment: FractionalOffset.bottomCenter),
              CheckboxListTile(title: Text(consentElement.acknowledgmentText), value: isChecked, onChanged: onChange),
              SizedBox(height: 40),
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

  ConsentElement(this.title, this.descriptionText, this.acknowledgmentText);
}
