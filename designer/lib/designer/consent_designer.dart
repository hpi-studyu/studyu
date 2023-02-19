import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer/designer/help_wrapper.dart';
import 'package:studyu_designer/models/app_state.dart';

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
      _consent.add(ConsentItem.withId());
    });
  }

  void _removeConsentItem(int index) {
    setState(() {
      _consent.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<AppState>().draftStudy == null) return Container();
    _consent = context.watch<AppState>().draftStudy.consent;

    return DesignerHelpWrapper(
      helpTitle: AppLocalizations.of(context).consent_help_title,
      helpText: AppLocalizations.of(context).consent_help_body,
      studyPublished: context.watch<AppState>().draftStudy.published,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ..._consent.asMap().entries.map(
                          (entry) => ConsentItemEditor(
                            key: UniqueKey(),
                            consentItem: entry.value,
                            remove: () => _removeConsentItem(entry.key),
                          ),
                        ),
                    const SizedBox(height: 200)
                  ],
                ),
              ),
            ),
          ),
          DesignerAddButton(label: Text(AppLocalizations.of(context).add_consent_item), add: _addConsentItem)
        ],
      ),
    );
  }
}
