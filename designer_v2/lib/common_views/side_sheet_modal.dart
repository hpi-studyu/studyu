import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_scaffold.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/theme.dart';

/// Displays a Material Side Sheet transitioned from Right side of the screen.
///
/// This function allows for customization of aspects of the Modal Side Sheet.
///
/// This function takes a `body` which is used to build the primary
/// content of the side sheet (typically a widget). Content below the side sheet
/// is dimmed with a [ModalBarrier]. The widget returned by the `body`
/// does not share a context with the location that `showModalSideSheet` is
/// originally called from. Use a [StatefulBuilder] or a custom
/// [StatefulWidget] if the side sheet needs to update dynamically. The
/// `body` argument cannot be null.
///
/// ### Note :
/// `ignoreAppBar` perameter determines that whether to show side sheet beneath the
/// [AppBar] or not. Default value of this perameter is `true`.
/// If this perameter set to `false`, the widget where you are calling[showModalSideSheet]
/// cannot be the direct child of the [Scaffold].
/// You must use a custom [Widget] or Wrap the used widget into [Builder] widget.
///
/// ##
/// `withCloseControll` perameter provide a Close Button on top right corner of the
/// side sheet to manually close the Modal Side Sheet. Default value is true.
/// If provided `false` you need to call [Navigator.of(context).pop()] method to close
/// the side sheet.
///
/// ##
/// `width` perameter gives a Width to the side sheet. For mobile devices default is 60%
/// of the device width and 25% for rest of the devices.
///
/// ## See Also
/// * The `context` argument is used to look up the [Navigator] for the
/// side sheet. It is only used when the method is called. Its corresponding widget
/// can be safely removed from the tree before the side sheet is closed.
///
/// * The `useRootNavigator` argument is used to determine whether to push the
/// side sheet to the [Navigator] furthest from or nearest to the given `context`.
/// By default, `useRootNavigator` is `true` and the side sheet route created by
/// this method is pushed to the root navigator.
///
/// * If the application has multiple [Navigator] objects, it may be necessary to
/// call `Navigator.of(context, rootNavigator: true).pop(result)` to close the
/// side sheet rather than just `Navigator.pop(context, result)`.
///
/// * The `barrierDismissible` argument is used to determine whether this route
/// can be dismissed by tapping the modal barrier. This argument defaults
/// to false. If `barrierDismissible` is true, a non-null `barrierLabel` must be
/// provided.
///
/// * The `barrierLabel` argument is the semantic label used for a dismissible
/// barrier. This argument defaults to `null`.
///
/// * The `barrierColor` argument is the color used for the modal barrier. This
/// argument defaults to `Color(0x80000000)`.
///
/// * The `transitionDuration` argument is used to determine how long it takes
/// for the route to arrive on or leave off the screen. This argument defaults
/// to 300 milliseconds.
///
/// * The `transitionBuilder` argument is used to define how the route arrives on
/// and leaves off the screen. By default, the transition is a linear fade of
/// the page's contents.
///
/// * The `routeSettings` will be used in the construction of the side sheet's route.
/// See [RouteSettings] for more details.
///
/// * Returns a [Future] that resolves to the value (if any) that was passed to
/// [Navigator.pop] when the side sheet was closed.
///
/// ##
/// * For more info on Modal Side Sheet see also : https://material.io/components/sheets-side#modal-side-sheet

Future<T?> showModalSideSheet<T extends Object?>(
    {required BuildContext context,
      required Widget body,
      bool barrierDismissible = false,
      Color barrierColor = const Color(0x80000000),
      double? width,
      double elevation = 8.0,
      Duration transitionDuration = const Duration(milliseconds: 300),
      String? barrierLabel = "Side Sheet",
      bool useRootNavigator = true,
      RouteSettings? routeSettings,
      bool withCloseControll = true,
      bool ignoreAppBar = true}) {
  var of = MediaQuery.of(context);
  var platform = Theme.of(context).platform;
  if (width == null) {
    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      width = of.size.width * 0.6;
    } else {
      width = of.size.width / 4;
    }
  }
  double exceptionalheight = !ignoreAppBar
      ? Scaffold.of(context).hasAppBar
      ? Scaffold.of(context).appBarMaxHeight!
      : 0
      : 0;
  double height = of.size.height - exceptionalheight;
  assert(!barrierDismissible || barrierLabel != null);
  return showGeneralDialog(
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    transitionDuration: transitionDuration,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    context: context,
    pageBuilder: (BuildContext context, _, __) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Material(
          elevation: 0,
          color: Colors.white,
          child: SizedBox(
            width: width,
            height: height,
            child: Scaffold(
              appBar: null,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.15),
              body: withCloseControll ? Stack(children: [
                  body,
                  const Positioned(top: 5, right: 5, child: CloseButton())
                ],
              ) : body,
            )
          )
        )
      );
    },
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
          child: child,
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
              .animate(animation));
    },
  );
}

typedef WidgetDecorator = Widget Function(Widget widget);

Future<T?> showDefaultSideSheet<T extends Object?>({
    required BuildContext context,
    required String title,
    required Widget body,
    required List<Widget> actionButtons,
    WidgetDecorator? wrapBody,
    width = 560,
    barrierColor = const Color(0xA8FFFFFF),
    barrierDismissible = true,
    ignoreAppBar = false,
    withCloseControll = false,
    bodyPaddingVertical = 32.0,
    bodyPaddingHorizontal = 48.0,
  }) {
  final theme = Theme.of(context);
  final wrapper = wrapBody ?? (widget) => widget; // default to identity no-op

  return showModalSideSheet(
    context: context,
    width: width,
    ignoreAppBar: ignoreAppBar,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    withCloseControll: withCloseControll,
    body: Container(
      decoration: BoxDecoration(
          border: Border(left: BorderSide(
            color: (theme.dividerTheme.color ?? theme.dividerColor).withOpacity(0.1)
          ))
      ),
      child: wrapper(Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  bodyPaddingHorizontal, bodyPaddingVertical,
                  bodyPaddingHorizontal, bodyPaddingVertical*0.5
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: theme.textTheme.headline5!
                      .copyWith(fontWeight: FontWeight.normal)),
                  Wrap(spacing: 8.0, children: actionButtons),
                ],
              ),
            ),
            const Divider(),
            Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(
                              bodyPaddingHorizontal, bodyPaddingVertical*0.5,
                              bodyPaddingHorizontal, bodyPaddingVertical
                          ),
                          child: body
                      )
                    ],
                  ),
                )
            ),
          ]
      )),
    ),
  );
}

showFormSideSheet<T extends FormViewModel>({
  required BuildContext context,
  required T formViewModel,
  required FormViewBuilder<T> formViewBuilder,
  List<Widget>? actionButtons,
  width = 560,
  barrierColor,
  barrierDismissible = true,
  ignoreAppBar = false,
  bodyPaddingVertical = 32.0,
  bodyPaddingHorizontal = 48.0,
}) {
  final defaultActionButtons = buildFormButtons(
      formViewModel, formViewModel.formMode);

  // Wraps the whole side sheet in a [ReactiveForm] widget
  Widget wrapBody(widget) {
    return ReactiveForm(
      formGroup: formViewModel.form,
      child: widget,
    );
  }

  barrierColor ??= ThemeConfig.modalBarrierColor(Theme.of(context));

  return showDefaultSideSheet(
    context: context,
    title: formViewModel.title,
    body: formViewBuilder(formViewModel),
    wrapBody: wrapBody,
    actionButtons: actionButtons ?? defaultActionButtons,
    width: width,
    barrierColor: barrierColor,
    barrierDismissible: barrierDismissible,
    ignoreAppBar: ignoreAppBar,
    bodyPaddingVertical: bodyPaddingVertical,
    bodyPaddingHorizontal: bodyPaddingHorizontal,
  );
}
