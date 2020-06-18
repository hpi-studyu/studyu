import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../routes.dart';
import '../util/localization.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('what_is_nof1')),
      ),
      body: PageView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(height: 100),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.coffee, size: 80, color: Colors.black),
                ),
                Expanded(
                  child: Icon(MdiIcons.equal, size: 80, color: Colors.black),
                ),
                Expanded(
                  child: Icon(MdiIcons.sleep, size: 80, color: Colors.black),
                ),
              ]),
              SizedBox(height: 100),
              Text(Nof1Localizations.of(context).translate('description_part1'),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
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
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(height: 100),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.help, size: 80, color: Colors.orange),
                ),
              ]),
              SizedBox(height: 100),
              Text(Nof1Localizations.of(context).translate('description_part2'),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
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
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(height: 100),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.exclamationThick, size: 80, color: Colors.blue),
                ),
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part3'),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
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
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(height: 100),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.accountQuestion, size: 80, color: Colors.blue),
                ),
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part4'),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
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
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(height: 100),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.notebookOutline, size: 80, color: Colors.blue),
                ),
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part5'),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
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
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              Image(image: AssetImage('assets/images/icon.png'), height: 100),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part6'),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              SizedBox(height: 40),
              RaisedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, Routes.terms),
                child: Text(Nof1Localizations.of(context).translate('get_started')),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
