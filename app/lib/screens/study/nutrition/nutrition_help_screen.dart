import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_core/core.dart';

class NutritionHelpScreen extends StatelessWidget {
  final NutritionTask task;

  const NutritionHelpScreen({required this.task, super.key});

  static MaterialPageRoute<void> route({required NutritionTask task}) =>
      MaterialPageRoute(builder: (_) => NutritionHelpScreen(task: task));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final instructions = task.instructions?.trim();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.help)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (instructions?.isNotEmpty == true) ...[
            Text(
              l10n.instructions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(instructions!),
            const SizedBox(height: 24),
          ],
          Text(
            l10n.daily_food_diary,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(l10n.nutrition_logging_guidance),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.push('/${RouteNames.faq}'),
            icon: const Icon(Icons.help_outline),
            label: Text(l10n.open_faq),
          ),
        ],
      ),
    );
  }
}
