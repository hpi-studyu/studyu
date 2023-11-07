import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/action_popup_menu.dart';
import 'package:studyu_designer_v2/common_views/async_value_widget.dart';
import 'package:studyu_designer_v2/common_views/layout_single_column.dart';
import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/sync_indicator.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/constants.dart';
import 'package:studyu_designer_v2/features/app_drawer.dart';
import 'package:studyu_designer_v2/features/design/study_form_providers.dart';
import 'package:studyu_designer_v2/features/forms/form_validation.dart';
import 'package:studyu_designer_v2/features/publish/study_publish_dialog.dart';
import 'package:studyu_designer_v2/features/study/study_controller.dart';
import 'package:studyu_designer_v2/features/study/study_controller_state.dart';
import 'package:studyu_designer_v2/features/study/study_navbar.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';
import 'package:studyu_designer_v2/features/study/study_status_badge.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/theme.dart';

abstract class IStudyAppBarViewModel implements IStudyStatusBadgeViewModel, IStudyNavViewModel {
  bool get isSyncIndicatorVisible;
  bool get isStatusBadgeVisible;
  bool get isPublishVisible;
}

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
    this.actionsSpacing = 2.0,
    this.actionsPadding = 4.0,
    this.appbarHeight = 56.0,
    this.appbarSubnavHeight = 44.0,
    super.key,
  });

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

  final double appbarHeight;
  final double appbarSubnavHeight;

  @override
  ConsumerState<StudyScaffold> createState() => _StudyScaffoldState();
}

class _StudyScaffoldState extends ConsumerState<StudyScaffold> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(studyControllerProvider(widget.studyId));

    final tabs = widget.tabs ?? StudyNav.tabs(widget.studyId, state);

    return Scaffold(
      appBar: AppBar(
        iconTheme: theme.iconTheme.copyWith(size: theme.iconTheme.size! * 1.2),
        bottom: (widget.tabsSubnav != null)
            ? PreferredSize(
                preferredSize: Size(double.infinity, widget.appbarSubnavHeight),
                child: Container(
                    //color: theme.colorScheme.primary.withOpacity(0.05),
                    color: theme.scaffoldBackgroundColor.withOpacity(0.15),
                    child: Row(
                      children: [
                        const SizedBox(width: 35.0),
                        Container(
                          constraints: const BoxConstraints(maxWidth: 750),
                          child: TabbedNavbar(
                            tabs: widget.tabsSubnav!,
                            selectedTab: widget.selectedTabSubnav,
                            height: widget.appbarSubnavHeight,
                            indicator: const BoxDecoration(),
                            isScrollable: true,
                          ),
                        )
                      ],
                    )))
            : null,
        toolbarHeight: widget.appbarHeight,
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
              flex: 8,
              child: AsyncValueWidget(
                value: state.study,
                data: (study) => Row(
                  children: [
                    Flexible(
                      child: Text(
                        state.titleText,
                        maxLines: 1,
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                    (state.isSyncIndicatorVisible) ? const SizedBox(width: 8.0) : const SizedBox.shrink(),
                    (state.isSyncIndicatorVisible)
                        ? IntrinsicWidth(
                            child: SyncIndicator(
                              state: state.syncState,
                              isDirty: state.isDirty,
                              lastSynced: state.lastSynced,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                loading: () => Container(),
                error: (e, str) => Container(),
              ),
            ),
            Flexible(
              flex: 11,
              child: TabbedNavbar(
                tabs: tabs,
                selectedTab: widget.selectedTab,
                height: widget.appbarHeight,
                disabledBackgroundColor: theme.appBarTheme.backgroundColor,
                disabledTooltipText: tr.navlink_unavailable_tooltip,
                isScrollable: true,
              ),
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
                      ...withSpacing(
                        [
                          (state.isStatusBadgeVisible)
                              ? StudyStatusBadge(
                                  status: state.studyStatus,
                                  participation: state.studyParticipation,
                                  showPrefixIcon: true,
                                )
                              : const SizedBox.shrink(),
                          (state.isStatusBadgeVisible) ? const SizedBox(width: 12.0) : const SizedBox.shrink(),
                          ...actionButtons(context),
                        ],
                        spacing: widget.actionsSpacing,
                        paddingStart: widget.actionsPadding,
                        paddingEnd: widget.actionsPadding,
                      ),
                    ].map((widget) => retainSizeInAppBar(widget)).toList(),
                  ),
                  loading: () => Container(), // TODO: loading skeleton
                  error: (e, str) => Container(),
                ),
              ],
      ),
      body: AsyncValueWidget(
        value: state.study,
        data: (study) => SingleColumnLayout.fromType(
          type: widget.layoutType ?? SingleColumnLayoutType.stretched,
          body: widget.body,
          header: widget.body.banner(context, ref),
          //stickyHeader: true,
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

    final theme = Theme.of(context);
    final controller = ref.watch(studyControllerProvider(widget.studyId).notifier);
    final state = ref.watch(studyControllerProvider(widget.studyId));

    if (state.isPublishVisible) {
      final formViewModel = ref.watch(studyPublishValidatorProvider(widget.studyId));
      final publishButton = ReactiveForm(
        formGroup: formViewModel.form,
        child: ReactiveFormConsumer(
            // enable re-rendering based on form validation status
            builder: (context, form, child) {
          return PrimaryButton(
            text: tr.action_button_study_launch,
            tooltipDisabled: "${tr.form_invalid_prompt}\n\n${form.validationErrorSummary}",
            icon: null,
            enabled: formViewModel.isValid,
            onPressed: () => showPublishDialog(context, widget.studyId),
          );
        }),
      );
      actionButtons.add(publishButton);
      actionButtons.add(const SizedBox(width: 12.0)); // padding
    }

    if (state.isSettingsEnabled) {
      actionButtons.add(IconButton(
        onPressed: controller.onSettingsPressed,
        icon: Icon(Icons.settings_rounded, size: theme.iconTheme.size),
        tooltip: tr.study_settings,
        color: theme.iconTheme.color?.faded(0.8),
        splashRadius: ThemeConfig.iconSplashRadius(theme),
      ));
    }

    actionButtons.add(
      ActionPopUpMenuButton(
        actions: controller.studyActions,
        orientation: Axis.vertical,
        enabled: state.study.hasValue, // disable while study is loading
        hideOnEmpty: false,
      ),
    );

    return actionButtons;
  }
}
