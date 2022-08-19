import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/badge.dart';
import 'package:studyu_designer_v2/common_views/layout_single_column.dart';
import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/sync_indicator.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/publish/study_publish_dialog.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/features/study/study_status_badge.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

/// Custom scaffold shared between all pages for an individual [Study]
class StudyScaffold extends ConsumerStatefulWidget {
  const StudyScaffold(
      {this.studyId = Config.newStudyId,
      required this.body,
      this.layoutType,
      this.tabs,
      this.tabsSubnav,
      this.selectedTab,
      this.selectedTabSubnav,
      this.drawer = const AppDrawer(title: 'StudyU'),
      this.disableActions = false,
      this.actionsSpacing = 8.0,
      this.actionsPadding = 12.0,
      Key? key})
      : super(key: key);

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
  final double actionsSpacing;
  final double actionsPadding;

  final SingleColumnLayoutType? layoutType;

  @override
  ConsumerState<StudyScaffold> createState() => _StudyScaffoldState();
}

class _StudyScaffoldState extends ConsumerState<StudyScaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(widget.studyId));
    final controller =
        ref.watch(studyControllerProvider(widget.studyId).notifier);

    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.iconTheme.copyWith(size: theme.iconTheme.size! * 1.2),
        bottom: (widget.tabsSubnav != null)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(50.0),
                child: Container(
                    //color: theme.colorScheme.primary.withOpacity(0.05),
                    color: theme.scaffoldBackgroundColor.withOpacity(0.15),
                    child: Row(
                      children: [
                        const SizedBox(width: 35.0),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 550),
                          child: TabbedNavbar(
                            tabs: widget.tabsSubnav!,
                            selectedTab: widget.selectedTabSubnav,
                            indicator: const BoxDecoration(),
                          ),
                        )
                      ],
                    )))
            : null,
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
                        softWrap: false),
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
              child: (widget.tabs != null)
                  ? Container(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: TabbedNavbar(
                        tabs: widget.tabs!,
                        selectedTab: widget.selectedTab,
                      ),
                    )
                  : Container(),
            ),
          ],
        ),
        //backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.5),
        actions: (widget.disableActions)
            ? null
            : [
                AsyncValueWidget(
                  value: state.study,
                  data: (study) => Row(
                    children: [
                      (state.isStatusBadgeVisible)
                          ? StudyStatusBadge(
                              status: state.studyStatus,
                              participation: state.studyParticipation,
                              showPrefixIcon: true,
                            )
                          : const SizedBox.shrink(),
                      ...withSpacing(
                        actionButtons(context),
                        spacing: widget.actionsSpacing,
                        paddingStart: widget.actionsPadding,
                        paddingEnd: widget.actionsPadding,
                      ),
                    ].map((widget) => retainSizeInAppBar(widget)).toList(),
                  ),
                  loading: () => Container(), // TODO: loading skeleton
                  error: (e, str) => Container(),
                ),
                ActionPopUpMenuButton(
                  actions: controller.studyActions,
                  orientation: Axis.vertical,
                  enabled:
                      state.study.hasValue, // disable while study is loading
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

  /// Note: This is not save to call until [StudyControllerState.study] is
  /// fully loaded (i.e. use inside of [AsyncValueWidget])
  List<Widget> actionButtons(BuildContext context) {
    List<Widget> actionButtons = [];

    final state = ref.watch(studyControllerProvider(widget.studyId));

    if (state.isPublishVisible) {
      final formViewModel =
          ref.watch(studyPublishValidatorProvider(widget.studyId));
      final publishButton = ReactiveForm(
        formGroup: formViewModel.form,
        child: ReactiveFormConsumer(
            // enable re-rendering based on form validation status
            builder: (context, form, child) {
          return PrimaryButton(
            text: "Launch".hardcoded,
            tooltipDisabled:
                "Please fill out all fields as required:".hardcoded +
                    "\n\n" +
                    form.validationErrorSummary,
            icon: null,
            enabled: formViewModel.isValid,
            onPressed: () => showPublishDialog(context, widget.studyId),
          );
        }),
      );
      actionButtons.add(publishButton);
    }

    return actionButtons;
  }
}
