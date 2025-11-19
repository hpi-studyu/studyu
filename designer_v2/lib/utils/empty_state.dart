import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const EmptyState({
    super.key,
    this.icon = Icons.search_off,
    required this.title,
    required this.message,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: theme.colorScheme.outline),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8, runSpacing: 8, alignment: WrapAlignment.center,
                children: [
                  if (primaryLabel != null)
                    FilledButton.icon(
                      onPressed: onPrimary,
                      icon: const Icon(Icons.undo),
                      label: Text(primaryLabel!),
                    ),
                  if (secondaryLabel != null)
                    OutlinedButton.icon(
                      onPressed: onSecondary,
                      icon: const Icon(Icons.clear_all),
                      label: Text(secondaryLabel!),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
