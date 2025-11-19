import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/domain/saved_filters.dart';
import 'package:studyu_designer_v2/localization/saved_filters_controller.dart';



class SaveAsDialog extends ConsumerStatefulWidget {
  const SaveAsDialog({super.key});
  @override
  ConsumerState<SaveAsDialog> createState() => _SaveAsDialogState();
}

class _SaveAsDialogState extends ConsumerState<SaveAsDialog> {
  final _nameCtrl = TextEditingController();
  FilterScope _scope = FilterScope.myStudies;
  bool _isDefault = false;

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save filter as…'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name', hintText: 'e.g., Recently Created'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<FilterScope>(
            value: _scope,
            items: const [
              DropdownMenuItem(value: FilterScope.myStudies, child: Text('Scope: My studies')),
              DropdownMenuItem(value: FilterScope.publicStudies, child: Text('Scope: Public studies')),
            ],
            onChanged: (v) => setState(() => _scope = v ?? FilterScope.myStudies),
            decoration: const InputDecoration(labelText: 'Scope'),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            value: _isDefault,
            onChanged: (v) => setState(() => _isDefault = v ?? false),
            title: const Text('Set as default (auto-apply on dashboard)'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () async {
            final name = _nameCtrl.text.trim();
            if (name.isEmpty) return;
            // Optional: capture current sort preset from your table state
            await ref.read(savedFiltersProvider.notifier).saveAs(
              name: name,
              scope: _scope,
              sortPreset: null,
            );
            if (_isDefault) {
              final list = ref.read(savedFiltersProvider).value ?? [];
              final justSaved = list.last;
              await ref.read(savedFiltersProvider.notifier).setDefault(justSaved.id);
            }
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
