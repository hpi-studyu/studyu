import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/layout_single_column.dart';
import 'package:studyu_designer_v2/common_views/layout_two_column.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/domain/forms/form_view_model.dart';

/// Signature for a builder that renders the widget corresponding to the
/// [FormViewModel] of type [T]
typedef FormViewBuilder<T extends FormViewModel> = Widget Function(T formViewModel);

/// Signature for a builder that resolves the [FormViewModel] of type [T]
/// via a Riverpod [WidgetRef]
typedef FormViewModelBuilder<T extends FormViewModel> = T Function(WidgetRef ref);

class FormScaffold<T extends FormViewModel> extends ConsumerWidget {
  const FormScaffold({
    required this.formViewModel,
    required this.body,
    this.actions,
    this.drawer,
    this.actionsSpacing = 8.0,
    this.actionsPadding = 24.0,
    Key? key
  }) : super(key: key);

  final T formViewModel;
  final List<Widget>? actions;
  final Widget body;
  final Widget? drawer;
  final double actionsSpacing;
  final double actionsPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultActionButtons = buildFormButtons(
        formViewModel, formViewModel.formMode);

    // Wraps the whole side sheet in a [ReactiveForm] widget
    Widget inForm(widget) {
      return ReactiveForm(
        formGroup: formViewModel.form,
        child: widget,
      );
    }

    final theme = Theme.of(context);

    return inForm(Scaffold(
      appBar: AppBar(
        iconTheme: theme.iconTheme,
        // TODO: enable async title here
        title: Text(formViewModel.title,
            maxLines: 1,
            style: Theme.of(context).textTheme.titleSmall,
            overflow: TextOverflow.ellipsis,
            softWrap: false
        ),
        actions: withSpacing(
          actions ?? defaultActionButtons,
          spacing: actionsSpacing,
          paddingStart: actionsPadding,
          paddingEnd: actionsPadding,
        ),
      ),
      body: body,
      drawer: drawer,
    ));
  }
}
