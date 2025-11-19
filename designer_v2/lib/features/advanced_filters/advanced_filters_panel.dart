import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/save_as_dialog.dart';
import 'package:studyu_designer_v2/common_views/saved_filters_sheet.dart';
import 'package:studyu_designer_v2/features/advanced_filters/quick_presets_bar.dart';

import 'filter_builder_container.dart';

class AdvancedFiltersPanel extends ConsumerWidget {
  AdvancedFiltersPanel({super.key});
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      key: _scaffoldKey,  
      appBar: AppBar(
        title: const Text('Advanced filters'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
                  IconButton(
                  tooltip: 'Saved filters',
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => const SavedFiltersSheet(), // ⬅️ new widget below
                  ),
                ),
          TextButton.icon(
            icon: const Icon(Icons.save_alt),
            label: const Text('Save as…'),
            onPressed: () => showDialog(context: context, builder: (_) => const SaveAsDialog()),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [ 
          Text(
            'Quick presets',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          QuickPresetsBar(),
          FilterBuilderContainer() ],
      ),
    );
  }

}




