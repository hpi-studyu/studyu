import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/common_views/under_construction.dart';
import 'package:studyu_designer_v2/features/study/study_page_view.dart';

class StudyMonitorScreen extends StudyPageWidget {
  const StudyMonitorScreen(super.studyId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.secondary.withOpacity(0.03),
      height: 300,
      child: const Center(
        child: UnderConstruction(),
      ),
    );
  }
}
