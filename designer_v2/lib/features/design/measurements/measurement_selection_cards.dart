import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';

class MeasurementSelectionCards extends StatelessWidget {
  const MeasurementSelectionCards({
    required this.onNewSurvey,
    required this.onNewNutrition,
    super.key,
  });

  final VoidCallback onNewSurvey;
  final VoidCallback onNewNutrition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          "Select Measurement Type",
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCard(
              context,
              title: "Survey",
              description:
                  "Collect self-reported data from participants using questions and scales.",
              icon: Icons.assignment_outlined,
              onTap: onNewSurvey,
            ),
            const SizedBox(width: 24.0),
            _buildCard(
              context,
              title: "Nutrition Task",
              description:
                  "Track participant food and drink intake using a structured journal or photo capture.",
              icon: Icons.restaurant,
              onTap: onNewNutrition,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return MouseEventsRegion(
      builder: (context, state) {
        final isHovered = state.contains(WidgetState.hovered);
        return SizedBox(
          width: 300,
          height: 350,
          child: Card(
            elevation: isHovered ? 8.0 : 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: BorderSide(
                color: isHovered
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 64.0, color: theme.colorScheme.primary),
                    const SizedBox(height: 24.0),
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.8,
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
