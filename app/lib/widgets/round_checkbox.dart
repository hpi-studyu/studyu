import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';

class RoundCheckbox extends StatelessWidget {
  final Function(bool)? onChanged;
  final bool? value;

  const RoundCheckbox({super.key, this.onChanged, this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: () {
        onChanged!(!value!);
      },
      icon: value!
          ? Icon(
              MdiIcons.checkboxMarkedCircleOutline,
              size: 30,
              color: theme.colorScheme.secondary,
            )
          : Icon(
              MdiIcons.checkboxBlankCircleOutline,
              size: 30,
              color: theme.colorScheme.secondary,
            ),
    );
  }
}
