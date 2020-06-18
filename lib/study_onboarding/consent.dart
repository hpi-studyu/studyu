import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../util/localization.dart';

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
          GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
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
                    child: Text('this'),
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
                    child: Text('is'),
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
                    child: Text('for'),
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
                    child: Text('getting'),
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
                    child: Text('your'),
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
                    child: Text('data'),
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
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(Nof1Localizations.of(context).translate('cancel')),
                ),
                RaisedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(Nof1Localizations.of(context).translate('accept')),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
