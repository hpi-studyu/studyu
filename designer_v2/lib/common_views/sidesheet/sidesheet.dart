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
  static double kDefaultWidth = 560;

  const Sidesheet({
    required this.titleText,
    this.body,
    this.tabs,
    this.actionButtons,
    this.width,
    this.withCloseButton = false,
    this.ignoreAppBar = true,
    this.collapseSingleTab = true,
    this.bodyPadding =
        const EdgeInsets.symmetric(vertical: 32.0, horizontal: 48.0),
    this.wrapContent,
    Key? key,
  })  : assert((body != null && tabs == null) || (body == null && tabs != null),
            "Must provide either body or tabs to build sidesheet content"),
        assert(tabs == null || tabs.length >= 1,
            "Must provide at least one tab to build sidesheet content"),
        super(key: key);

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

  _onTabChange(int tabIdx, SidesheetTab selectedTab) {
    setState(() {
      this.selectedTab = selectedTab;
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

    final backgroundColor =
        ThemeConfig.sidesheetBackgroundColor(Theme.of(context));

    return Align(
      alignment: Alignment.bottomRight,
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

    final hasTabs = tabs != null;
    final isCollapsed =
        tabs != null && tabs.length == 1 && widget.collapseSingleTab;

    final innerBody = (body != null)
        ? body
        : (selectedTab != null)
            ? selectedTab!.builder(context)
            : const SizedBox.shrink();

    final actualWrapContent =
        widget.wrapContent ?? (widget) => widget; // default to identity no-op

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: (theme.dividerTheme.color ?? theme.dividerColor)
                .withOpacity(0.1),
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
                  Text(
                    widget.titleText,
                    style: theme.textTheme.headline5!
                        .copyWith(fontWeight: FontWeight.normal),
                  ),
                  (widget.actionButtons != null)
                      ? Wrap(spacing: 8.0, children: widget.actionButtons!)
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            (hasTabs && !isCollapsed)
                ? Column(
                    children: [
                      const SizedBox(height: 32.0),
                      TabbedNavbar<SidesheetTab>(
                        tabs: tabs,
                        onSelect: _onTabChange,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            const Divider(),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
  Duration transitionDuration = const Duration(milliseconds: 300),
  String? barrierLabel = "Sidesheet",
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
}) {
  assert(!barrierDismissible || barrierLabel != null);
  return showGeneralDialog(
    barrierDismissible: barrierDismissible,
    barrierColor:
        barrierColor ?? ThemeConfig.modalBarrierColor(Theme.of(context)),
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
        child: child,
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(animation),
      );
    },
  );
}
