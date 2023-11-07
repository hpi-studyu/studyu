import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyu_core/core.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import 'onboarding_progress.dart';

class JourneyOverviewScreen extends StatefulWidget {
  const JourneyOverviewScreen({super.key});

  @override
  State<JourneyOverviewScreen> createState() => _JourneyOverviewScreen();
}

class _JourneyOverviewScreen extends State<JourneyOverviewScreen> {
  StudySubject? subject;

  Future<void> getConsentAndNavigateToDashboard(BuildContext context) async {
    bool? consentGiven;
    if (subject!.study.hasConsentCheck) {
      consentGiven = await Navigator.pushNamed<bool>(context, Routes.consent);
    } else {
      consentGiven = true;
    }
    if (!mounted) return;
    if (consentGiven != null && consentGiven) {
      Navigator.pushNamed(context, Routes.kickoff);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.user_did_not_give_consent),
          duration: const Duration(seconds: 30),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    subject = context.read<AppState>().activeSubject;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.your_journey),
        leading: Icon(MdiIcons.mapMarkerPath),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                //StudyTile.fromUserStudy(study: study),
                Timeline(subject: subject),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: () => getConsentAndNavigateToDashboard(context),
        progress: const OnboardingProgress(stage: 2, progress: 0.5),
      ),
    );
  }
}

class Timeline extends StatelessWidget {
  final StudySubject? subject;

  const Timeline({required this.subject, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interventionsInOrder = subject!.getInterventionsInOrder();
    final now = DateTime.now();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...interventionsInOrder.asMap().entries.map((entry) {
          final index = entry.key;
          final intervention = entry.value;
          return InterventionTile(
            title: intervention.name,
            iconName: intervention.icon,
            color: intervention.isBaseline() ? Colors.grey : theme.colorScheme.secondary,
            date: now.add(Duration(days: index * subject!.study.schedule.phaseDuration)),
            isFirst: index == 0,
          );
        }),
        InterventionTile(
          title: AppLocalizations.of(context)!.journey_results_available,
          iconName: 'flagCheckered',
          color: Colors.green,
          isLast: true,
          date: subject!.endDate(now),
        )
      ],
    );
  }
}

class InterventionTile extends StatelessWidget {
  final String? title;
  final String iconName;
  final DateTime date;
  final Color? color;
  final bool isFirst;
  final bool isLast;

  const InterventionTile({
    required this.title,
    required this.iconName,
    required this.date,
    this.color,
    this.isFirst = false,
    this.isLast = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.4,
      isFirst: isFirst,
      isLast: isLast,
      indicatorStyle: IndicatorStyle(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        indicator: IconIndicator(iconName: iconName, color: color),
      ),
      beforeLineStyle: LineStyle(color: theme.primaryColor),
      afterLineStyle: LineStyle(color: theme.primaryColor),
      endChild: TimelineChild(
        child: Text(title!, style: theme.textTheme.titleLarge!.copyWith(color: theme.primaryColor)),
      ),
      startChild: TimelineChild(
        child: Text(DateFormat('dd-MM-yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class IconIndicator extends StatelessWidget {
  final String iconName;
  final Color? color;

  const IconIndicator({required this.iconName, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(shape: BoxShape.circle, color: color ?? Theme.of(context).colorScheme.secondary),
      child: Center(
        child: Icon(MdiIcons.fromString(iconName), color: Colors.white),
      ),
    );
  }
}

class TimelineChild extends StatelessWidget {
  final Widget? child;

  const TimelineChild({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minHeight: 100),
      child: Center(
        child: child,
      ),
    );
  }
}
