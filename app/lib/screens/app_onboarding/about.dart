import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/util/localization.dart';

import '../../routes.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('what_is_studyu')),
      ),
      body: PageView(
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
              SizedBox(height: 50),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.food, size: 80, color: Colors.black),
                ),
                Expanded(
                  child: Icon(MdiIcons.equal, size: 80, color: Colors.black),
                ),
                Expanded(
                  child: Icon(MdiIcons.sleepOff, size: 80, color: Colors.black),
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
              SizedBox(height: 50),
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
              SizedBox(height: 50),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.accountQuestion, size: 80, color: Colors.blue),
                ),
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part3'),
                  textAlign: TextAlign.justify, style: TextStyle(fontSize: 18)),
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
              SizedBox(height: 50),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.exclamationThick, size: 80, color: Colors.blue),
                )
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part4'),
                  textAlign: TextAlign.justify, style: TextStyle(fontSize: 18)),
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
              SizedBox(height: 50),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.alphaNBoxOutline, size: 80, color: Colors.blue),
                ),
                Expanded(
                    child: Text(
                  'of',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30),
                )),
                Expanded(
                  child: Icon(MdiIcons.numeric1BoxOutline, size: 80, color: Colors.blue),
                ),
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part5'),
                  textAlign: TextAlign.justify, style: TextStyle(fontSize: 18)),
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
              SizedBox(height: 50),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.notebookOutline, size: 80, color: Colors.blue),
                ),
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part6'),
                  textAlign: TextAlign.justify, style: TextStyle(fontSize: 18)),
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
              SizedBox(height: 50),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.alignVerticalBottom, size: 80, color: Colors.blue),
                ),
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part7'),
                  textAlign: TextAlign.justify, style: TextStyle(fontSize: 18)),
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
              SizedBox(height: 50),
              Row(children: [
                Expanded(
                  child: Icon(MdiIcons.progressCheck, size: 80, color: Colors.blue),
                ),
              ]),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part8'),
                  textAlign: TextAlign.justify, style: TextStyle(fontSize: 18)),
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
              Image(image: AssetImage('assets/images/icon_wide.png'), height: 200),
              SizedBox(height: 50),
              Text(Nof1Localizations.of(context).translate('description_part9'),
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
              SizedBox(height: 40),
              OutlineButton.icon(
                icon: Icon(MdiIcons.rocket),
                onPressed: () => Navigator.pushNamed(context, Routes.terms),
                label: Text(Nof1Localizations.of(context).translate('get_started'),
                    style: Theme.of(context)
                        .textTheme
                        .button
                        .copyWith(color: Theme.of(context).primaryColor, fontSize: 20)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
