import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/features/forms/form_view_model.dart';

/// Utility widget that can listen to [ReactiveForm] by wrapping itself in
/// a [ReactiveFormConsumer]. Conceptually this is very similar to
/// Riverpod's [ConsumerWidget].
///
/// The [FormConsumerWidget] is reactively rebuild when the nearest
/// [FormGroup] ancestor in the widget tree (provided by [ReactiveForm])
/// updates.
///
/// Use this for presentational widgets that render a form & are controlled by
/// a [FormViewModel].
///
/// For convenience, we directly extend Riverpod's [ConsumerStatefulWidget]
/// instead of [StatefulWidget] so that [ConsumerStatefulWidget.ref] is
/// accessible.
///
/// Note: If rebuilding the whole form view results in poor performance,
/// consider using [ReactiveFormConsumer] selectively.
///
abstract class FormConsumerWidget extends StatefulWidget {
  const FormConsumerWidget({super.key});

  Widget build(BuildContext context, FormGroup form);

  @override
  State<FormConsumerWidget> createState() => _FormConsumerWidgetState();
}

class _FormConsumerWidgetState extends State<FormConsumerWidget> {
  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(builder: (context, form, _) {
      return widget.build(context, form);
    });
  }
}

/// Utility widget that combines Riverpod's [ConsumerStatefulWidget] with
/// our reactive forms [FormConsumerWidget] helper
abstract class FormConsumerRefWidget extends ConsumerStatefulWidget {
  const FormConsumerRefWidget({super.key});

  Widget build(BuildContext context, FormGroup form, WidgetRef ref);

  @override
  ConsumerState<FormConsumerRefWidget> createState() => _FormConsumerRefWidgetState();
}

class _FormConsumerRefWidgetState extends ConsumerState<FormConsumerRefWidget> {
  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(builder: (context, form, _) {
      return widget.build(context, form, ref);
    });
  }
}
