import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/form_buttons.dart';
import 'package:studyu_designer_v2/common_views/utils.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';
import 'package:studyu_designer_v2/features/forms/unsaved_changes_dialog.dart';
import 'package:studyu_designer_v2/theme.dart';

/// Signature for a builder that renders the widget corresponding to the
/// [FormViewModel] of type [T]
typedef FormViewBuilder<T extends FormViewModel> = Widget Function(T formViewModel);

/// Signature for a builder that resolves the [FormViewModel] of type [T]
/// via a Riverpod [WidgetRef]
typedef FormViewModelBuilder<T extends FormViewModel> = T Function(WidgetRef ref);

class FormScaffold<T extends FormViewModel> extends ConsumerStatefulWidget {
  const FormScaffold(
      {required this.formViewModel,
      required this.body,
      this.actions,
      this.drawer,
      this.actionsSpacing = 8.0,
      this.actionsPadding = 24.0,
      super.key});

  final T formViewModel;
  final List<Widget>? actions;
  final Widget body;
  final Widget? drawer;
  final double actionsSpacing;
  final double actionsPadding;

  @override
  ConsumerState<FormScaffold<T>> createState() => _FormScaffoldState();
}

class _FormScaffoldState<T extends FormViewModel> extends ConsumerState<FormScaffold<T>> {
  T get formViewModel => widget.formViewModel;

  ModalRoute<dynamic>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route?.removeScopedWillPopCallback(_promptBackNavigationConfirmation);
    _route = ModalRoute.of(context);
    _route?.addScopedWillPopCallback(_promptBackNavigationConfirmation);
  }

  @override
  void dispose() {
    _route?.removeScopedWillPopCallback(_promptBackNavigationConfirmation);
    _route = null;
    super.dispose();
  }

  Future<bool> _promptBackNavigationConfirmation() async {
    if (!formViewModel.isDirty) {
      return true;
    }
    final shouldPop = await showDialog<bool>(
      context: context,
      barrierColor: ThemeConfig.modalBarrierColor(Theme.of(context)),
      builder: (context) => const UnsavedChangesDialog(),
    );
    if (shouldPop!) {
      await formViewModel.cancel();
    }
    return shouldPop;
  }

  @override
  Widget build(BuildContext context) {
    final defaultActionButtons = buildFormButtons(formViewModel, formViewModel.formMode);

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
            softWrap: false),
        actions: withSpacing(
          widget.actions ?? defaultActionButtons,
          spacing: widget.actionsSpacing,
          paddingStart: widget.actionsPadding,
          paddingEnd: widget.actionsPadding,
        ),
      ),
      body: widget.body,
      drawer: widget.drawer,
    ));
  }
}
