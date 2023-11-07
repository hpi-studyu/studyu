import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/app_state.dart';
import 'report_details.dart';

class ReportHistoryScreen extends StatelessWidget {
  const ReportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.report_history,
        ),
      ),
      body: RetryFutureBuilder<List<StudySubject>>(
        tryFunction: () => StudySubject.getStudyHistory(Supabase.instance.client.auth.currentUser!.id),
        successBuilder: (BuildContext context, List<StudySubject>? pastStudies) {
          return ListView.builder(
            itemCount: pastStudies!.length,
            itemBuilder: (context, index) {
              return ReportHistoryItem(pastStudies[index]);
            },
          );
        },
      ),
    );
  }
}

class ReportHistoryItem extends StatelessWidget {
  final StudySubject subject;

  const ReportHistoryItem(this.subject, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final model = context.watch<AppState>();
    final isActiveStudy = model.activeSubject!.studyId == subject.studyId;
    return Card(
      color: isActiveStudy ? Colors.green[600] : theme.cardColor,
      child: InkWell(
        onTap: () {
          Navigator.push(context, ReportDetailsScreen.routeFor(subject: subject));
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(
                  MdiIcons.fromString(subject.study.iconName) ?? MdiIcons.accountHeart,
                  color: isActiveStudy ? Colors.white : Colors.black,
                ),
                Text(
                  subject.study.title!,
                  style: theme.textTheme.headlineSmall!.copyWith(color: isActiveStudy ? Colors.white : Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
