import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../routes.dart';
import '../util/localization.dart';
import '../util/user.dart';

class ConsentScreen extends StatefulWidget {
  @override
  _ConsentScreenState createState() => _ConsentScreenState();
}

/*
class ChangeButtonBackground extends StatefulWidget {
  @override
  ChangeButtonBackgroundState createState() {
    return new ChangeButtonBackgroundState();
  }
}

class ChangeButtonBackgroundState extends State<ChangeButtonBackground> {
  List<Color> _colors = [
    //Get list of colors
    Colors.red,
    Colors.blue,
    Colors.brown,
    Colors.teal,
    Colors.purple
  ];
  int _currentIndex = 0;

  _onChanged() {
    //update with a new color when the user taps button
    int _colorCount = _colors.length;
    setState(() {
      if (_currentIndex == _colorCount - 1) {
        _currentIndex = 0;
      } else {
        _currentIndex += 1;
      }
    });
    //setState(() => (_currentIndex == _colorCount - 1) ? _currentIndex = 1 : _currentIndex += 1);
  }
}

 */

class _ConsentScreenState extends State<ConsentScreen> {
  bool _box1 = true;
  bool _box2 = true;
  bool _box3 = true;
  bool _box4 = true;
  bool _box5 = true;
  bool _box6 = true;

  bool userCanContinue() {
    return _box1 && _box2 && _box3 && _box4 && _box5 && _box6;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einverständnis'),
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
          GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            // child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Card(
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
                        ...buildSection(theme,
                            title: 'Box 1',
                            descriptionText: 'this',
                            acknowledgmentText: 'I agree',
                            onChange: (val) => setState(() => _box1 = val),
                            isChecked: _box1),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.blue[200],
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
                        ...buildSection(theme,
                            title: 'Box 2',
                            descriptionText: 'is',
                            acknowledgmentText: 'I agree',
                            onChange: (val) => setState(() => _box2 = val),
                            isChecked: _box2),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.blue[300],
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
                        ...buildSection(theme,
                            title: 'Box 3',
                            descriptionText: 'for',
                            acknowledgmentText: 'I agree',
                            onChange: (val) => setState(() => _box3 = val),
                            isChecked: _box3),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.blue[400],
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
                        ...buildSection(theme,
                            title: 'Box 4',
                            descriptionText: 'getting',
                            acknowledgmentText: 'I agree',
                            onChange: (val) => setState(() => _box4 = val),
                            isChecked: _box4),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.blue[500],
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
                        ...buildSection(theme,
                            title: 'Box 5',
                            descriptionText: 'you',
                            acknowledgmentText: 'I agree',
                            onChange: (val) => setState(() => _box5 = val),
                            isChecked: _box5),
                      ],
                    ),
                  ),
                ),
              ),
              Card(
                color: Colors.blue[600],
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
                        ...buildSection(theme,
                            title: 'Box 6',
                            descriptionText: 'informed',
                            acknowledgmentText: 'I agree',
                            onChange: (val) => setState(() => _box6 = val),
                            isChecked: _box6),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            // ),
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
                  onPressed: userCanContinue()
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

List<Widget> buildSection(ThemeData theme,
    {String title, String descriptionText, String acknowledgmentText, Function onChange, bool isChecked}) {
  return <Widget>[
    Text(title, style: theme.textTheme.headline5),
    Text(descriptionText),
    Align(alignment: FractionalOffset.bottomCenter),
    CheckboxListTile(title: Text(acknowledgmentText), value: isChecked, onChanged: onChange),
    SizedBox(height: 40),
  ];
}
