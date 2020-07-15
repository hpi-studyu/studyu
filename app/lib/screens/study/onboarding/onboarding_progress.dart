import 'package:flutter/material.dart';

class OnboardingProgress extends StatelessWidget implements PreferredSizeWidget {
  final int stage;
  final double progress;

  const OnboardingProgress({@required this.stage, @required this.progress, Key key}) : super(key: key);

  double _getProgressForStage(int stage) {
    if (stage < this.stage) return 1;
    if (stage == this.stage) return progress;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: LinearProgressIndicator(value: _getProgressForStage(0))),
        SizedBox(width: 4),
        Expanded(child: LinearProgressIndicator(value: _getProgressForStage(1))),
        SizedBox(width: 4),
        Expanded(child: LinearProgressIndicator(value: _getProgressForStage(2))),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(4);
}
