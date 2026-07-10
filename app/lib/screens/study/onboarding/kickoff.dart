import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/util/cache.dart';
import 'package:studyu_app/util/dashboard_showcase.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class KickoffScreen extends StatefulWidget {
  const KickoffScreen({super.key});

  @override
  State<KickoffScreen> createState() => _KickoffScreen();
}

class _KickoffScreen extends State<KickoffScreen> {
  StudySubject? subject;
  bool ready = false;

  Future<void> _storeUserStudy(BuildContext context) async {
    try {
      // Start study at the next day
      final now = DateTime.now();
      subject!.startedAt = DateTime(now.year, now.month, now.day + 1).toUtc();
      subject = await subject!.save();
      subject = await _fetchRemoteSubject(subject!.id);
      if (!context.mounted) return;
      context.read<AppState>().activeSubject = subject;
      context.read<AppState>().init(context);
      await Cache.storeSubject(context.read<AppState>().activeSubject);
      await storeActiveSubjectId(subject!.id);
      if (!context.mounted) return;
      context.read<AppState>().showRecoveryPhraseOnDashboard = true;
      await RecoveryPhraseStorage.markPending(subject!.id);
      if (!context.mounted) return;
      setState(() => ready = true);
      context.go('/${RouteNames.dashboard}');
    } catch (e) {
      StudyULogger.fatal('Failed creating subject: $e');
    }
  }

  Future<StudySubject?> _fetchRemoteSubject(String selectedStudyObjectId) {
    StudyULogger.debug('Fetching subject with ID: $selectedStudyObjectId');
    return SupabaseQuery.getById<StudySubject>(
      selectedStudyObjectId,
      selectedColumns: [
        '*',
        // Retrieve the related study along with its fitbit credentials
        'study!study_subject_studyId_fkey(*, study_fitbit_credentials:study_fitbit_credentials_studyId_fkey(*))',
        'subject_progress(*)',
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    subject = context.read<AppState>().activeSubject;
    _storeUserStudy(context);
  }

  Widget _constructStatusIcon(BuildContext context) => !ready
      ? const SizedBox(
          height: 64,
          width: 64,
          child: CircularProgressIndicator(),
        )
      : const Icon(
          MdiIcons.checkboxMarkedCircle,
          color: Colors.green,
          size: 64,
        );

  String _getStatusText(BuildContext context) => !ready
      ? AppLocalizations.of(context)!.setting_up_study
      : AppLocalizations.of(context)!.good_to_go;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subject!.study.title!),
        leading: Icon(MdiIconsHelper.fromString(subject!.study.iconName)),
      ),
      body: Builder(
        builder: (buildContext) {
          return Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _constructStatusIcon(context),
                    const SizedBox(height: 32),
                    Text(
                      _getStatusText(context),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    /*OutlinedButton(
                      onPressed: () => _storeUserStudy(context),
                      child: Text(AppLocalizations.of(context)!.start_study),
                    ),*/
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
