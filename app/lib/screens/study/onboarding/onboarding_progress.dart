import 'package:flutter/material.dart';

class OnboardingProgress extends StatelessWidget {
  final int stage;
  final double progress;

  const OnboardingProgress({required this.stage, required this.progress, super.key});

  double _getProgressForStage(int stage) {
    if (stage < this.stage) return 1;
    if (stage == this.stage) return progress;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _getProgressForStage(0)),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _getProgressForStage(1)),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: _getProgressForStage(2)),
          ),
        ),
      ],
    );
  }
}
