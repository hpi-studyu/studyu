import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:studyu_core/core.dart';

Widget interventionIcon(Intervention intervention, {Color? color}) {
  if (intervention.isBaseline()) {
    return Icon(MdiIcons.rayStart, color: color ?? Colors.white);
  }

  return intervention.icon.isNotEmpty
      ? Icon(
          MdiIcons.fromString(intervention.icon),
          color: color ?? Colors.white,
        )
      : Text(
          intervention.name![0].toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.white,
          ),
        );
}
