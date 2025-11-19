import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/saved_filters.dart';
import 'package:studyu_designer_v2/localization/saved_filters_controller.dart';

// Placeholder: replace with real backend call
final studiesCountProvider = FutureProvider.family<int, SavedFilter>((ref, f) async {
  // compile f.logicTree -> query; call your API here
  return 0;
});

class SavedFiltersDrawer extends ConsumerWidget {
  const SavedFiltersDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(savedFiltersProvider);
    return Drawer(
      child: SafeArea(
        child: state.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (list) => ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) => _SavedFilterTile(f: list[i]),
          ),
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
      leading: f.isDefault ? const Icon(Icons.star, color: Colors.amber) : const Icon(Icons.filter_alt),
      title: Text(f.name),
      subtitle: Text('${f.scope.name} · last used: ${f.lastUsedAt?.toLocal().toString().split(".").first ?? "—"}'),
      trailing: countAsync.when(
        loading: () => const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const Text('–'),
        data: (n) => Chip(label: Text('$n')),
      ),
      onTap: () async {
        ref.read(activeFilterFromSavedProvider.notifier).state = f;
        await ref.read(savedFiltersProvider.notifier).touchLastUsed(f.id);
        if (context.mounted) Navigator.of(context).maybePop();
      },
      onLongPress: () => _overflow(context, ref),
    );
  }

  void _overflow(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
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
