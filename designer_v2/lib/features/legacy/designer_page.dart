import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/legacy/designer.dart';
import 'package:studyu_designer_v2/features/legacy/designer/app_state.dart';
import 'package:provider/provider.dart' as p;

/// Helper widget that re-exposes the legacy state object managed by Riverpod
/// through a standard [Provider] for compatibility of legacy widgets
class DesignerScreen extends ConsumerWidget {
  const DesignerScreen(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(legacyAppStateProvider(studyId).notifier);
    return p.ChangeNotifierProvider(
        create: (_) => appState,
        builder: (context, child) {
          return Designer(studyId: studyId);
        }
    );
  }
}
