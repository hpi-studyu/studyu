import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class UnderConstruction extends StatelessWidget {
  const UnderConstruction({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EmptyBody(
      icon: Icons.construction_rounded,
      title: "Under construction".hardcoded,
      description: "We are still busy working on this part, check back soon!".hardcoded,
    );
  }
}
