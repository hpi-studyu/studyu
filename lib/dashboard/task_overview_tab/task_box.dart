import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:pimp_my_button/pimp_my_button.dart';

import '../../tasks/dashboard_task.dart';

class TaskBox extends StatefulWidget {
  final DashboardTask task;

  const TaskBox({@required this.task});

  @override
  State<TaskBox> createState() => _TaskBoxState();
}

class _TaskBoxState extends State<TaskBox> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => widget.task));
        },
        child: Row(
          children: [
            Expanded(
              child: ListTile(
                leading: widget.task.icon,
                title: Text(widget.task.title),
                subtitle: Text(widget.task.description),
              ),
            ),
            RoundCheckbox(
              value: _checked,
              onChanged: (value) {
                setState(() {
                  _checked = value;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}

class RoundCheckbox extends StatelessWidget {
  final Function(bool) onChanged;
  final bool value;

  const RoundCheckbox({Key key, this.onChanged, this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PimpedButton(
      particle: DemoParticle(),
      pimpedWidgetBuilder: (context, controller) {
        return IconButton(
          onPressed: () {
            onChanged(!value);
            controller.forward(from: 0);
          },
          icon: value
              ? Icon(
                  MdiIcons.checkboxMarkedCircleOutline,
                  size: 30,
                  color: theme.accentColor,
                )
              : Icon(
                  MdiIcons.checkboxBlankCircleOutline,
                  size: 30,
                  color: theme.accentColor,
                ),
        );
      },
    );
  }
}
