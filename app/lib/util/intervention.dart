import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyou_core/core.dart';

Widget interventionIcon(Intervention intervention, {Color color}) {
  if (isBaseline(intervention)) return Icon(MdiIcons.rayStart, color: color ?? Colors.white);

  return intervention.icon != null && intervention.icon.isNotEmpty
      ? Icon(MdiIcons.fromString(intervention.icon), color: color ?? Colors.white)
      : Text(intervention.name[0].toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.white));
}

bool isBaseline(Intervention intervention) => intervention.name == 'Baseline';
