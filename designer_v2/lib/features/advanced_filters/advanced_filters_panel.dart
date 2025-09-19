import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'advanced_filters_state.dart';

class AdvancedFiltersPanel extends ConsumerWidget {
  const AdvancedFiltersPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(advancedFiltersOpenProvider.notifier).state = false;
            Navigator.of(context).maybePop();
          },
          tooltip: 'Close',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Quick filters', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              FilterChip(label: Text('Status: running'), selected: false, onSelected: null),
              FilterChip(label: Text('Status: draft'), selected: false, onSelected: null),
              FilterChip(label: Text('Owner: me'), selected: false, onSelected: null),
            ],
          ),
          const SizedBox(height: 24),
          Text('Builders', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.text_fields),
                    title: Text('Title contains'),
                    subtitle: Text('e.g., "sleep"'),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text('Created: rolling window'),
                    subtitle: Text('Last 30 days'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset'),
                onPressed: () {/* clear draft later */},
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Apply'),
                onPressed: () {
                  // TODO: wire to actual filter provider in follow-up task
                  Navigator.of(context).maybePop();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tip: You\'ll be able to combine AND / OR / NOT in the next step.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
