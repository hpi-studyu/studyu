import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/banner.dart';

abstract class StudyPageWidget extends ConsumerWidget
    implements IBannerProvider {
  const StudyPageWidget(this.studyId, {Key? key}) : super(key: key);

  final String studyId;

  @override
  Widget? banner(BuildContext context) {
    return null; // override in subclasses to provide an optional banner
  }
}
