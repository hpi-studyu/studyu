import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/empty_body.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_controller.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_scaffold.dart';
import 'package:studyu_designer_v2/features/dashboard/dashboard_state.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_table.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/repositories/user_repository.dart';
import 'package:studyu_designer_v2/services/simplified_study_service.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({required this.filter, super.key});

  final StudiesFilter? filter;

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const Duration _databaseConsistencyDelay = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    final controller = ref.read(dashboardControllerProvider.notifier);
    runAsync(() => controller.setStudiesFilter(widget.filter));
  }

  Future<void> _ensureDatabaseConsistency() async {
    await Future.delayed(_databaseConsistencyDelay);
  }

  @override
  void didUpdateWidget(DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter != widget.filter) {
      final controller = ref.read(dashboardControllerProvider.notifier);
      runAsync(() => controller.setStudiesFilter(widget.filter));
    }
  }

  Future<void> _showImportDialog(BuildContext context) async {
    final studyService = ref.read(simplifiedStudyServiceProvider);
    final dashboardController = ref.read(dashboardControllerProvider.notifier);
    final textController = TextEditingController();
    String? errorText;
    var isLoading = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog(
              title: Text(tr.dialog_import_study_title),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tr.dialog_import_study_description),
                    const SizedBox(height: 12.0),
                    TextField(
                      controller: textController,
                      maxLines: 14,
                      decoration: InputDecoration(
                        labelText: tr.dialog_import_study_input_label,
                        hintText: tr.dialog_import_study_input_hint,
                        errorText: errorText,
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(tr.dialog_cancel),
                ),
                FilledButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final raw = textController.text.trim();
                          if (raw.isEmpty) {
                            setState(() {
                              errorText = tr.dialog_import_study_error_empty;
                            });
                            return;
                          }
                          setState(() {
                            errorText = null;
                            isLoading = true;
                          });
                          final navigator = Navigator.of(dialogContext);
                          try {
                            final importedStudy = await studyService
                                .importStudyFromJson(raw);
                            if (!mounted || !navigator.mounted) {
                              return;
                            }
                            navigator.pop();
                            await _ensureDatabaseConsistency();
                            dashboardController.onSelectStudy(importedStudy);
                          } catch (error) {
                            setState(() {
                              errorText = error is FormatException
                                  ? error.message
                                  : error.toString();
                              isLoading = false;
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(tr.dialog_import_study_confirm),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ref.watch(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    return DashboardScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              SizedBox(
                height: 36.0,
                child: PrimaryButton(
                  text: tr.action_button_new_study,
                  onPressed: controller.onClickNewStudy,
                ),
              ),
              const SizedBox(width: 12.0),
              SizedBox(
                height: 36.0,
                child: SecondaryButton(
                  text: tr.action_button_import_study,
                  icon: Icons.file_upload_outlined,
                  onPressed: () => _showImportDialog(context),
                ),
              ),
              const SizedBox(width: 28.0),
              SelectableText(
                state.visibleListTitle,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(width: 28.0),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Search(
                      searchController: state.searchController,
                      hintText: tr.search,
                      onQueryChanged: (query) =>
                          controller.filterStudies(query),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0), // spacing between body elements
          FutureBuilder<StudyUUser>(
            future: ref.read(userRepositoryProvider).fetchUser(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return AsyncValueWidget<List<Study>>(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  value: state.displayedStudies(
                    snapshot.data!.preferences.pinnedStudies,
                    state.query,
                  ),
                  data: (visibleStudies) => StudiesTable(
                    studies: visibleStudies,
                    pinnedStudies: snapshot.data!.preferences.pinnedStudies,
                    dashboardController: ref.watch(
                      dashboardControllerProvider.notifier,
                    ),
                    onSelect: controller.onSelectStudy,
                    getActions: controller.availableActions,
                    emptyWidget:
                        (widget.filter == null ||
                            widget.filter == StudiesFilter.owned)
                        ? (state.query.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: EmptyBody(
                                    icon: Icons.content_paste_search_rounded,
                                    title: tr.studies_not_found,
                                    description: tr.modify_query,
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.only(top: 24.0),
                                  child: EmptyBody(
                                    icon: Icons.content_paste_search_rounded,
                                    title: tr.studies_empty,
                                    description: tr.studies_empty_description,
                                    // "...or create a new draft copy from an already published study!",
                                    /* button: PrimaryButton(text: "From template",); */
                                  ),
                                )
                        : const SizedBox.shrink(),
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }
}
