import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:studyu_app/app_router.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/models/app_state.dart';
import 'package:studyu_app/screens/study/dashboard/task_overview_tab/task_overview.dart';
import 'package:studyu_app/util/debug_screen.dart';
import 'package:studyu_core/core.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  final String? error;

  const DashboardScreen({super.key, this.error});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class OverflowMenuItem {
  final String name;
  final IconData icon;
  final String? routeName;
  final Function()? onTap;

  OverflowMenuItem(this.name, this.icon, {this.routeName, this.onTap});
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  StudySubject? subject;
  List<TaskInstance>? scheduleToday;

  bool get showNextDay =>
      (kDebugMode || context.read<AppState>().isPreview) &&
      !subject!.completedStudy;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        setState(() {
          scheduleToday = subject!.scheduleFor(DateTime.now());
        });
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subject = context.watch<AppState>().activeSubject;
    if (subject != null) {
      scheduleToday = subject!.scheduleFor(DateTime.now());
      if (widget.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(widget.error!)));
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (subject == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.go(RoutePaths.loading);
      });
      return const SizedBox.shrink();
    }

    final isPreviewMode = context.read<AppState>().isPreview;

    return Scaffold(
      appBar: AppBar(
        // Removes back button. We currently keep navigation stack to make developing easier
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.dashboard),
        forceMaterialTransparency: true,
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.contact,
            icon: Icon(MdiIcons.faceAgent),
            onPressed: () {
              context.push(RoutePaths.contact);
            },
          ),
          IconButton(
            tooltip: AppLocalizations.of(context)!.current_report,
            icon: Icon(MdiIcons.chartBar),
            onPressed: () =>
                context.push(RoutePaths.reportDetails, extra: subject),
          ),
          PopupMenuButton<OverflowMenuItem>(
            onSelected: (value) {
              if (value.routeName != null) {
                context.push(value.routeName!);
              } else {
                value.onTap?.call();
              }
            },
            itemBuilder: (context) {
              return [
                OverflowMenuItem(
                  AppLocalizations.of(context)!.report_history,
                  MdiIcons.history,
                  routeName: RoutePaths.reportHistory,
                ),
                OverflowMenuItem(
                  AppLocalizations.of(context)!.faq,
                  MdiIcons.frequentlyAskedQuestions,
                  routeName: RoutePaths.faq,
                ),
                OverflowMenuItem(
                  AppLocalizations.of(context)!.settings,
                  Icons.settings,
                  routeName: RoutePaths.appSettings,
                ),
                OverflowMenuItem(
                  AppLocalizations.of(context)!.what_is_studyu,
                  MdiIcons.helpCircleOutline,
                  routeName: RoutePaths.about,
                ),
                OverflowMenuItem(
                  AppLocalizations.of(context)!.about,
                  MdiIcons.informationOutline,
                  onTap: () async {
                    final iconAuthors = ['Kiranshastry'];
                    final PackageInfo packageInfo =
                        await PackageInfo.fromPlatform();
                    if (!context.mounted) return;
                    showAboutDialog(
                      context: context,
                      applicationIcon: InkWell(
                        onDoubleTap: () {
                          DebugScreen.showDebugScreen(context);
                        },
                        child: const Image(
                          image: AssetImage('assets/icon/icon.png'),
                          height: 32,
                        ),
                      ),
                      applicationVersion:
                          '${packageInfo.version} - ${packageInfo.buildNumber}',
                      children: [
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.black),
                            children: [
                              const TextSpan(text: 'Icons from '),
                              TextSpan(
                                style: const TextStyle(color: Colors.blue),
                                text: 'www.flaticon.com',
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    launchUrl(
                                      Uri.parse('https://www.flaticon.com/'),
                                    );
                                  },
                              ),
                              const TextSpan(text: ' made by'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Column(
                          children: iconAuthors
                              .map(
                                (author) => InkWell(
                                  onTap: () {
                                    launchUrl(
                                      Uri.parse(
                                        'https://www.flaticon.com/authors/${author.replaceAll(RegExp(r'\s|_'), '-')}',
                                      ),
                                    );
                                  },
                                  child: Text(
                                    author,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  },
                ),
              ].map((choice) {
                return PopupMenuItem<OverflowMenuItem>(
                  value: choice,
                  child: Row(
                    children: [
                      Icon(choice.icon, color: Colors.black),
                      const SizedBox(width: 8),
                      Text(choice.name),
                    ],
                  ),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Preview mode banner
          if (isPreviewMode)
            GestureDetector(
              onTap: () => _showPreviewModeInfo(context),
              child: Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.preview,
                      color: Colors.orange.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.preview_mode_active,
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade800,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          // Main content
          Expanded(
            child: Padding(
              padding: showNextDay
                  ? EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height / 10,
                    )
                  : EdgeInsets.zero,
              child: _buildBody(),
            ),
          ),
        ],
      ),
      bottomSheet: showNextDay
          ? Container(
              margin: const EdgeInsets.only(left: 16, bottom: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.fast_forward_rounded),
                onPressed: () async {
                  try {
                    await subject!.setStartDateBackBy(days: 1);
                    setState(() {
                      scheduleToday = subject!.scheduleFor(DateTime.now());
                    });
                  } on SocketException catch (_) {}
                },
                label: Text(AppLocalizations.of(context)!.next_day),
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(color: Colors.orange, width: 2.0),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : null,
    );
  }

  void _showPreviewModeInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.preview, color: Colors.orange),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.preview_mode),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(AppLocalizations.of(context)!.preview_mode_description),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text(AppLocalizations.of(context)!.ok),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody() {
    if (subject!.completedStudy) {
      return const StudyFinishedPlaceholder();
    } else if (subject!.startedAt!.isAfter(DateTime.now())) {
      final theme = Theme.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32, 32, 32, 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.study_not_started,
                style: TextStyle(
                  fontSize: 20,
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return TaskOverview(
        subject: subject,
        scheduleToday: scheduleToday,
        interventionIcon: subject!.getInterventionForDate(DateTime.now())?.icon,
      );
    }
  }
}

class StudyFinishedPlaceholder extends StatelessWidget {
  static const space = SizedBox(height: 80);

  const StudyFinishedPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.completed_study,
              style: TextStyle(
                fontSize: 20,
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            space,
            OutlinedButton.icon(
              onPressed: () => context.push(RoutePaths.reportHistory),
              icon: Icon(MdiIcons.history, size: 24),
              label: Text(
                AppLocalizations.of(context)!.report_history,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            space,
            OutlinedButton.icon(
              onPressed: () => context.push(RoutePaths.studySelection),
              icon: Icon(MdiIcons.clipboardArrowRightOutline, size: 24),
              label: Text(
                AppLocalizations.of(context)!.study_selection,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
