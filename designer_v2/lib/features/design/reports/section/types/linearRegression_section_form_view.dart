import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../report_item_form_controller.dart';

class LinearRegressionSectionFormView extends ConsumerWidget {
  const LinearRegressionSectionFormView({super.key, required this.formViewModel});

  final ReportSectionFormViewModel formViewModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text("Linear Regression");
    // TODO: implement build
    //throw UnimplementedError();
  }
}
