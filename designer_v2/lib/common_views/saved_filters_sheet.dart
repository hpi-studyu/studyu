import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/saved_filters.dart';
import 'package:studyu_designer_v2/localization/saved_filters_controller.dart';

// If you already have a real count provider, keep using it.
// Otherwise this placeholder returns 0 for now.
final studiesCountProvider = FutureProvider.family<int, SavedFilter>((ref, f) async => 0);

class SavedFiltersSheet extends ConsumerWidget {
  const SavedFiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedFiltersProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, scroll) {
        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              const _SheetHandle(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Text('Saved filters', style: Theme.of(context).textTheme.titleLarge),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Refresh',
                      icon: const Icon(Icons.refresh),
                      onPressed: () => ref.read(savedFiltersProvider.notifier).refresh(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: state.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (list) {
                    if (list.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('No saved filters yet.\nUse “Save as…” to add one.',
                              textAlign: TextAlign.center),
                        ),
                      );
                    }
                    return ListView.separated(
                      controller: scroll,
                      padding: const EdgeInsets.all(12),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => _SavedFilterTile(f: list[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Container(
        width: 42,
        height: 5,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }
}

class _SavedFilterTile extends ConsumerWidget {
  const _SavedFilterTile({required this.f});
  final SavedFilter f;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(studiesCountProvider(f));

    return ListTile(
      leading: f.isDefault
          ? const Icon(Icons.star, color: Colors.amber)
          : const Icon(Icons.filter_alt),
      title: Text(f.name),
      subtitle: Text(
        '${f.scope.name} · last used: ${f.lastUsedAt?.toLocal().toString().split(".").first ?? "—"}',
      ),
      trailing: countAsync.when(
        loading: () => const SizedBox(
          width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const Text('–'),
        data: (n) => Chip(label: Text('$n')),
      ),
      onTap: () async {
        // Apply this saved filter to the dashboard/panel
        // ref.read(activeFilterFromSavedProvider.notifier).state = f;
        ref.read(activeFilterFromSavedProvider.notifier).state = f;
        await ref.read(savedFiltersProvider.notifier).touchLastUsed(f.id);
        if (context.mounted) Navigator.of(context).maybePop(); // close sheet
      },
      onLongPress: () => _overflow(context, ref),
    );
  }

  // void _overflow(BuildContext context, WidgetRef ref) {
  //   showModalBottomSheet(
  //     context: context,
  //     builder: (_) => SafeArea(
  //       child: Column(mainAxisSize: MainAxisSize.min, children: [
  //         ListTile(
  //           leading: const Icon(Icons.star),
  //           title: const Text('Set as default'),
  //           onTap: () async {
  //             await ref.read(savedFiltersProvider.notifier).setDefault(f.id);
  //             if (context.mounted) Navigator.pop(context);
  //           },
  //         ),
  //         ListTile(
  //           leading: const Icon(Icons.delete_outline),
  //           title: const Text('Delete'),
  //           onTap: () async {
  //             await ref.read(savedFiltersProvider.notifier).delete(f.id);
  //             if (context.mounted) Navigator.pop(context);
  //           },
  //         ),
  //       ]),
  //     ),
  //   );
  // }

  void _overflow(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController(text: f.name);

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Rename'),
            onTap: () async {
              Navigator.pop(context); // close sheet
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Rename filter'),
                  content: TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
                  ],
                ),
              );
              if (ok == true) {
                await ref.read(savedFiltersProvider.notifier).rename(f.id, nameCtrl.text.trim());
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Set as default'),
            onTap: () async {
              await ref.read(savedFiltersProvider.notifier).setDefault(f.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Delete'),
            onTap: () async {
              await ref.read(savedFiltersProvider.notifier).delete(f.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }


}
