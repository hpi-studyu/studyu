import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';
import 'package:studyu_designer_v2/repositories/model_repository.dart';

abstract class StudyPageWidget extends ConsumerWidget implements IWithBanner {
  const StudyPageWidget(this.studyCreationArgs, {super.key});

  final StudyCreationArgs studyCreationArgs;

  @override
  Widget? banner(BuildContext context, WidgetRef ref) {
    return null; // override in subclasses to provide an optional banner
  }
}
