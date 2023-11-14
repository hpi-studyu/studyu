import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/theme.dart';

class SidesheetTab extends NavbarTab {
  SidesheetTab({
    required super.title,
    required super.index,
    required this.builder,
    super.enabled,
  });

  /// The widget to be rendered as the [Sidesheet.body] when the tab is selected
  WidgetBuilder builder;
}

class Sidesheet extends StatefulWidget {
  static double kDefaultWidth = 740;

  const Sidesheet({
    required this.titleText,
    this.body,
    this.tabs,
    this.actionButtons,
    this.width,
    this.withCloseButton = false,
    this.ignoreAppBar = true,
    this.collapseSingleTab = false,
    this.bodyPadding = const EdgeInsets.symmetric(vertical: 32.0, horizontal: 48.0),
    this.wrapContent,
    super.key,
  })  : assert((body != null && tabs == null) || (body == null && tabs != null),
            "Must provide either body or tabs to build sidesheet content"),
        assert(tabs == null || tabs.length >= 1, "Must provide at least one tab to build sidesheet content");

  final String titleText;
  final Widget? body;
  final List<SidesheetTab>? tabs;
  final List<Widget>? actionButtons;
  final double? width;
  final bool withCloseButton;
  final bool ignoreAppBar;
  final bool collapseSingleTab;
  final EdgeInsets? bodyPadding;
  final WidgetDecorator? wrapContent;

  @override
  State<Sidesheet> createState() => _SidesheetState();
}

class _SidesheetState extends State<Sidesheet> {
  SidesheetTab? selectedTab;

  @override
  void initState() {
    if (widget.tabs != null) {
      selectedTab = widget.tabs![0];
    }
    super.initState();
  }

  void _onTabChange(int tabIdx, NavbarTab selectedTab) {
    setState(() {
      this.selectedTab = selectedTab as SidesheetTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context);

    final actualWidth = widget.width ?? Sidesheet.kDefaultWidth;
    final exceptionalHeight = !widget.ignoreAppBar
        ? Scaffold.of(context).hasAppBar
            ? Scaffold.of(context).appBarMaxHeight!
            : 0
        : 0;
    final actualHeight = screen.size.height - exceptionalHeight;

    final backgroundColor = ThemeConfig.sidesheetBackgroundColor(Theme.of(context));

    return Align(
      alignment: Alignment.bottomLeft,
      child: Material(
        elevation: 0,
        color: Colors.white,
        child: SizedBox(
          width: actualWidth,
          height: actualHeight,
          child: Scaffold(
            appBar: null,
            backgroundColor: backgroundColor,
            body: widget.withCloseButton
                ? Stack(
                    children: [
                      _build(context, widget.body, widget.tabs),
                      const Positioned(
                        top: 5,
                        right: 5,
                        child: CloseButton(),
                      )
                    ],
                  )
                : _build(context, widget.body, widget.tabs),
          ),
        ),
      ),
    );
  }

  _build(BuildContext context, Widget? body, List<SidesheetTab>? tabs) {
    final theme = Theme.of(context);
    final backgroundColor = ThemeConfig.sidesheetBackgroundColor(Theme.of(context));

    final hasTabs = tabs != null;
    final isCollapsed = tabs != null && tabs.length == 1 && widget.collapseSingleTab;

    final innerBody = (body != null)
        ? body
        : (selectedTab != null)
            ? selectedTab!.builder(context)
            : const SizedBox.shrink();

    final actualWrapContent = widget.wrapContent ?? (widget) => widget; // default to identity no-op

    final tabBarLabelHoverColor =
        (theme.tabBarTheme.labelColor ?? theme.tabBarTheme.labelStyle?.color)?.faded(ThemeConfig.kHoverFadeFactor);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: (theme.dividerTheme.color ?? theme.dividerColor).withOpacity(0.1),
          ),
        ),
      ),
      child: actualWrapContent(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                (widget.bodyPadding?.horizontal ?? 0) * 0.5,
                (widget.bodyPadding?.vertical ?? 0) * 0.5,
                (widget.bodyPadding?.horizontal ?? 0) * 0.5,
                (widget.bodyPadding?.vertical ?? 0) * 0.25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SelectableText(
                    widget.titleText,
                    style: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.normal),
                  ),
                  (widget.actionButtons != null)
                      ? Wrap(spacing: 8.0, children: widget.actionButtons!)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            (hasTabs && !isCollapsed)
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: (widget.bodyPadding?.horizontal ?? 0) * 0.5),
                    child: TabbedNavbar<SidesheetTab>(
                      tabs: tabs,
                      height: 38.0,
                      onSelect: _onTabChange,
                      labelPadding: EdgeInsets.zero,
                      labelSpacing: 24.0,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.label,
                      backgroundColor: backgroundColor,
                      overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.transparent,
                      ),
                      labelColorHover: tabBarLabelHoverColor,
                      unselectedLabelColorHover: tabBarLabelHoverColor,
                    ),
                  )
                : const SizedBox.shrink(),
            (hasTabs && !isCollapsed) ? const Divider(height: 1) : const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    (hasTabs && !isCollapsed) // compensate for divider height loss
                        ? const SizedBox(height: 12.0)
                        : const SizedBox.shrink(),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        (widget.bodyPadding?.horizontal ?? 0) * 0.5,
                        (widget.bodyPadding?.vertical ?? 0) * 0.25,
                        (widget.bodyPadding?.horizontal ?? 0) * 0.5,
                        (widget.bodyPadding?.vertical ?? 0) * 0.5,
                      ),
                      child: innerBody,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<T?> showModalSideSheet<T extends Object?>({
  required BuildContext context,
  required String title,
  Widget? body,
  List<SidesheetTab>? tabs,
  List<Widget>? actionButtons,
  WidgetDecorator? wrapContent,
  double? width,
  bool withCloseButton = false,
  bool ignoreAppBar = true,
  bool barrierDismissible = true,
  Color? barrierColor,
  Duration transitionDuration = const Duration(milliseconds: 500),
  String? barrierLabel = "Sidesheet",
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  assert(!barrierDismissible || barrierLabel != null);
  return showGeneralDialog(
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor ?? ThemeConfig.modalBarrierColor(Theme.of(context)),
    transitionDuration: transitionDuration,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    context: context,
    pageBuilder: (BuildContext context, _, __) => Sidesheet(
      body: body,
      tabs: tabs,
      wrapContent: wrapContent,
      width: width,
      withCloseButton: withCloseButton,
      ignoreAppBar: ignoreAppBar,
      actionButtons: actionButtons,
      titleText: title,
    ),
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(animation),
        child: child,
      );
    },
  );
}
