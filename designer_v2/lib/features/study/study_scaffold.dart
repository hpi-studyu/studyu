import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/layout_single_column.dart';
import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/common_views/sync_indicator.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';

/// Custom scaffold shared between all pages for an individual [Study]
class StudyScaffold extends ConsumerStatefulWidget {
  const StudyScaffold({
    this.studyId = Config.newStudyId,
    required this.body,
    this.layoutType,
    this.tabs,
    this.tabsSubnav,
    this.selectedTab,
    this.selectedTabSubnav,
    this.drawer = const AppDrawer(title: 'StudyU'),
    this.disableActions = false,
    Key? key
  }) : super(key: key);

  /// The currently selected [Study.id]
  /// Defaults to [Config.newStudyId] when creating a new study
  final String studyId;

  final List<NavbarTab>? tabs;
  final List<NavbarTab>? tabsSubnav;
  final NavbarTab? selectedTab;
  final NavbarTab? selectedTabSubnav;

  /// The widget to be rendered as the main page body
  final StudyPageWidget body;

  final Widget? drawer;
  final bool disableActions;

  final SingleColumnLayoutType? layoutType;

  @override
  ConsumerState<StudyScaffold> createState() => _StudyScaffoldState();
}

class _StudyScaffoldState extends ConsumerState<StudyScaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(widget.studyId));
    final controller = ref.watch(studyControllerProvider(widget.studyId).notifier);

    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.iconTheme.copyWith(size: theme.iconTheme.size! * 1.2),
        bottom: (widget.tabsSubnav != null) ? PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            //color: theme.colorScheme.primary.withOpacity(0.05),
            color: theme.scaffoldBackgroundColor.withOpacity(0.15),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Container(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: TabbedNavbar(
                    tabs: widget.tabsSubnav!,
                    selectedTab: widget.selectedTabSubnav,
                    indicator: const BoxDecoration(),
                  ),
                )
              ],
            )
          )) : null,
        title: Row(
          children: [
            // Use the title widget slot to render both the title and a
            // tabbed control for switching between different pages (combined
            // in a [Row] widget).
            //
            // Alternatively, [Appbar.flexibleSpace] would be suitable for
            // rendering the tabbed navigation. But since [Appbar.flexibleSpace]
            // is stacked behind the app bar, we'd have to manually manage
            // responsive layout conflicts (the tabbed control would be overlaid
            // by the app bar widgets).
            Expanded(
              flex: 4,
              child: AsyncValueWidget(
                value: state.study,
                data: (study) => Row(
                  children: [
                    Text(state.titleText,
                        maxLines: 1,
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false
                    ),
                    const SizedBox(width: 8.0),
                    SyncIndicator(
                      state: state.study,
                      isDirty: state.isDirty,
                      lastSynced: state.lastSynced,
                    )
                  ],
                ),
                loading: () => Container(),
                error: (e, str) => Container(),
              ),
            ),
            Flexible(
              flex: 5,
              child: (widget.tabs != null) ? Container(
                constraints: const BoxConstraints(maxWidth: 420),
                child: TabbedNavbar(
                  tabs: widget.tabs!,
                  selectedTab: widget.selectedTab,
                ),
              ) : Container(),
            ),
          ],
        ),
        //backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
        actions: (widget.disableActions) ? null : [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.center,
            child: AsyncValueWidget(
              value: state.study,
              data: (study) => Text(state.statusText,
                  maxLines: 1,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.clip,
                  softWrap: false
              ),
              loading: () => Container(),
              error: (e, str) => Container(),
            ),
          ),
          ActionPopUpMenuButton(
            actions: controller.studyActions,
            orientation: Axis.vertical,
            hideOnEmpty: false,
          ),
        ],
      ),
      body: AsyncValueWidget(
        value: state.study,
        data: (study) => SingleColumnLayout.fromType(
          type: widget.layoutType ?? SingleColumnLayoutType.stretched,
          body: widget.body,
          header: widget.body.banner(context, ref),
          context: context,
        ),
      ),
      drawer: widget.drawer,
    );
  }
}
