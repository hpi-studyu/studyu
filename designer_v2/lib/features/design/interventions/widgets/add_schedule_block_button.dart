import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

class AddScheduleBlockButton extends StatelessWidget {
  final Function(StudyScheduleSegmentType) onPressed;

  const AddScheduleBlockButton({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<StudyScheduleSegmentType>(
      onSelected: onPressed,
      itemBuilder: (context) {
        return StudyScheduleSegmentType.values.map((type) {
          return PopupMenuItem(
            value: type,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getSegmentColor(type),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(type.string),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: theme.colorScheme.onPrimary),
            const SizedBox(width: 6.0),
            Text(
              "Add Schedule Block", // todo localize
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSegmentColor(StudyScheduleSegmentType type) {
    switch (type) {
      case StudyScheduleSegmentType.baseline:
        return const Color(0xFF3B82F6); // Blue
      case StudyScheduleSegmentType.alternating:
        return const Color(0xFF10B981); // Green
      case StudyScheduleSegmentType.counterBalanced:
        return const Color(0xFF8B5CF6); // Purple
      case StudyScheduleSegmentType.thompsonSampling:
        return const Color(0xFFF59E0B); // Orange
      case StudyScheduleSegmentType.singleIntervention:
        return const Color(0xFFEC4899); // Pink
    }
  }
}
