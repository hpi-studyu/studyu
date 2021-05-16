import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

Widget publishedIcon() => IconLabel(label: 'Published', iconData: MdiIcons.checkBold, color: Colors.green);

Widget draftIcon() => IconLabel(label: 'Draft', iconData: MdiIcons.fileDocumentEdit, color: Colors.amber);

Widget openParticipationIcon() =>
    IconLabel(label: 'Open for all', iconData: MdiIcons.lockOpenVariant, color: Colors.blue);

Widget inviteParticipationIcon() => IconLabel(label: 'Invite only', iconData: MdiIcons.lock, color: Colors.orange);

Widget publicResultsIcon() => IconLabel(label: 'Public results', iconData: MdiIcons.accountGroup, color: Colors.blue);

Widget privateResultsIcon() =>
    IconLabel(label: 'Private results', iconData: MdiIcons.accountLock, color: Colors.orange);

class IconLabel extends StatelessWidget {
  final String label;
  final IconData iconData;
  final Color color;
  final double width;

  const IconLabel({@required this.label, @required this.iconData, @required this.color, this.width, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 140,
      child: TextButton.icon(
        onPressed: null,
        icon: Icon(iconData, color: color),
        label: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}
