import 'package:flutter/material.dart';

import '../../util/localization.dart';

class Contact extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        Nof1Localizations.of(context).translate('contact'),
      ),
    );
  }
}
