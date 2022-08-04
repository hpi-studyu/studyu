import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/primary_button.dart';
import 'package:studyu_designer_v2/common_views/secondary_button.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

/// A cancel / dismiss button for use with [FormScaffold] [showFormSideSheet)
/// Heavily inspired by [CloseButton]
class DismissButton extends StatelessWidget {
  const DismissButton({
    this.text,
    this.onPressed,
    Key? key
  }) : super(key: key);

  /// An override callback to perform instead of the default behavior which is
  /// to pop the [Navigator].
  ///
  /// It can, for instance, be used to pop the platform's navigation stack
  /// via [SystemNavigator] instead of Flutter's [Navigator] in add-to-app
  /// situations.
  ///
  /// Defaults to null.
  final VoidCallback? onPressed;

  final String? text;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return SecondaryButton(
      text: text ?? "Cancel".hardcoded,
      icon: null,
      //tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}

List<Widget> buildFormButtons(FormViewModel formViewModel, FormMode formMode) {
  // Allows the wrapped [widget] to retain its preferred size & avoid
  // being stretched when placed into the [AppBar] actions
  // Note: [AppBar] places the actions in a [CrossAxisAlignment.stretched] row
  _retainSizeInAppBar(Widget widget) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [widget],
    );
  }

  final modifyActionButtons = [
    ReactiveFormConsumer( // enable re-rendering based on form validation status
        builder: (context, form, child) {
          return _retainSizeInAppBar(DismissButton(
            onPressed: () =>
                formViewModel.cancel().then(
                        (_) => Navigator.maybePop(context)),
          ));
        }
    ),
    ReactiveFormConsumer( // enable re-rendering based on form validation status
        builder: (context, form, child) {
          print("rebuild button");
          return _retainSizeInAppBar(PrimaryButton(
            text: "Save".hardcoded,
            tooltipDisabled: "Please fill out all fields as required".hardcoded,
            icon: null,
            onPressed: (formViewModel.isValid) ?
                () => formViewModel.save().then(
                  // Close the form (side sheet or scaffold route) if future
                  // completed successfully
                  (value) => Navigator.maybePop(context).then((_) => print(formViewModel.isValid))
                ) : null,
          ));
        }
    ),
  ];
  final readonlyActionButtons = [
    // TODO: clean this up more
    ReactiveFormConsumer( // enable re-rendering based on form validation status
        builder: (context, form, child) {
          return _retainSizeInAppBar(DismissButton(
            text: "Close".hardcoded,
            onPressed: () =>
                formViewModel.cancel().then(
                        (_) => Navigator.maybePop(context)),
          ));
        }
    ),
  ];

  final defaultActionButtons = {
    FormMode.create: modifyActionButtons,
    FormMode.edit: modifyActionButtons,
    FormMode.readonly: readonlyActionButtons,
  }[formViewModel.formMode] ?? modifyActionButtons;

  return defaultActionButtons;
}
