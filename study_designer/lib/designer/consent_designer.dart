import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/consent/consent_item.dart';
import 'package:studyou_core/util/localization.dart';

import '../models/designer_state.dart';
import '../widgets/consent/consent_item_editor.dart';
import '../widgets/util/designer_add_button.dart';

class ConsentDesigner extends StatefulWidget {
  @override
  _ConsentDesignerState createState() => _ConsentDesignerState();
}

class _ConsentDesignerState extends State<ConsentDesigner> {
  List<ConsentItem> _consent;

  void _addConsentItem() {
    setState(() {
      _consent.add(ConsentItem.designerDefault());
    });
  }

  void _removeConsentItem(index) {
    setState(() {
      _consent.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _consent = context.watch<DesignerState>().draftStudy.studyDetails.consent;
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  ..._consent
                      .asMap()
                      .entries
                      .map((entry) => ConsentItemEditor(
                          key: UniqueKey(), consentItem: entry.value, remove: () => _removeConsentItem(entry.key)))
                      .toList(),
                  SizedBox(height: 200)
                ],
              ),
            ),
          ),
        ),
        DesignerAddButton(
            label: Text(Nof1Localizations.of(context).translate('add_consent_item')), add: _addConsentItem)
      ],
    );
  }
}
