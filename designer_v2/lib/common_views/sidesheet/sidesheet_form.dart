import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/form_scaffold.dart';
import 'package:studyu_designer_v2/common_views/navbar_tabbed.dart';
import 'package:studyu_designer_v2/common_views/sidesheet/sidesheet.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/theme.dart';

class FormSideSheetTab<T extends FormViewModel> extends NavbarTab {
  FormSideSheetTab({
    required super.title,
    required super.index,
    required this.formViewBuilder,
    super.enabled,
  });

  /// The widget to be rendered as the sidesheet content with a [FormViewModel]
  /// of type [T] when the tab is selected
  FormViewBuilder<T> formViewBuilder;
}

Future<Object?> showFormSideSheet<T extends FormViewModel>({
  required BuildContext context,
  required T formViewModel,
  FormViewBuilder<T>? formViewBuilder,
  List<FormSideSheetTab<T>>? tabs,
  List<Widget>? actionButtons,
  double? width,
  bool withCloseButton = false,
  bool ignoreAppBar = true,
  bool barrierDismissible = false,
  Color? barrierColor,
}) {
  barrierColor ??= ThemeConfig.modalBarrierColor(Theme.of(context));

  // Wraps the whole side sheet in a [ReactiveForm] widget
  Widget wrapInForm(Widget widget) {
    return ReactiveForm(
      formGroup: formViewModel.form,
      child: widget,
    );
  }

  // Bind the [formViewModel] to the [SidesheetTab]s' widget builder
  final List<SidesheetTab>? boundTabs = tabs
      ?.map(
        (t) => SidesheetTab(
          title: t.title,
          index: t.index,
          enabled: t.enabled,
          builder: (BuildContext context) => t.formViewBuilder(formViewModel),
        ),
      )
      .toList();

  return showModalSideSheet(
    context: context,
    title: formViewModel.title,
    body: formViewBuilder?.call(formViewModel), // inject viewmodel
    tabs: boundTabs,
    actionButtons: actionButtons ??
        buildFormButtons(
          formViewModel,
          formViewModel.formMode,
        ),
    wrapContent: wrapInForm,
    width: width,
    withCloseButton: withCloseButton,
    ignoreAppBar: ignoreAppBar,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
  );
}
