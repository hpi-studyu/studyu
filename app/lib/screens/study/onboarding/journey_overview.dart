import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:studyou_core/models/models.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../../models/app_state.dart';
import '../../../routes.dart';
import '../../../util/intervention.dart';
import '../../../util/localization.dart';
import '../../../widgets/bottom_onboarding_navigation.dart';
import 'onboarding_progress.dart';

class JourneyOverviewScreen extends StatefulWidget {
  @override
  _JourneyOverviewScreen createState() => _JourneyOverviewScreen();
}

class _JourneyOverviewScreen extends State<JourneyOverviewScreen> {
  ParseUserStudy study;

  Future<void> getConsentAndNavigateToDashboard(BuildContext context) async {
    final consentGiven = await Navigator.pushNamed(context, Routes.consent);
    if (consentGiven != null && consentGiven) {
      Navigator.pushNamed(context, Routes.kickoff);
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(Nof1Localizations.of(context).translate('user_did_not_give_consent')),
        duration: Duration(seconds: 30),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    study = context.read<AppState>().activeStudy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Nof1Localizations.of(context).translate('your_journey')),
        leading: Icon(MdiIcons.mapMarkerPath),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                //StudyTile.fromUserStudy(study: study),
                Timeline(study: study),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomOnboardingNavigation(
        onNext: () => getConsentAndNavigateToDashboard(context),
        progress: OnboardingProgress(stage: 2, progress: 0.5),
      ),
    );
  }
}

class Timeline extends StatelessWidget {
  final UserStudyBase study;

  const Timeline({@required this.study, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final interventionsInOrder = study.getInterventionsInOrder();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ...interventionsInOrder.asMap().entries.map((entry) {
          final index = entry.key;
          final intervention = entry.value;
          return InterventionTile(
            title: intervention.name,
            iconName: intervention.icon,
            color: isBaseline(intervention) ? Colors.grey : theme.accentColor,
            date: study.startDate.add(Duration(days: index * study.schedule.phaseDuration)),
            isFirst: index == 0,
          );
        }).toList(),
        InterventionTile(
            title: Nof1Localizations.of(context).translate('journey_results_available'),
            iconName: 'flagCheckered',
            color: Colors.green,
            isLast: true,
            date: study.endDate)
      ],
    );
  }
}

class InterventionTile extends StatelessWidget {
  final String title;
  final String iconName;
  final DateTime date;
  final Color color;
  final bool isFirst;
  final bool isLast;

  const InterventionTile(
      {@required this.title,
      @required this.iconName,
      @required this.date,
      this.color,
      this.isFirst = false,
      this.isLast = false,
      Key key})
      : super(key: key);

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
        child: Text(title, style: theme.textTheme.headline6.copyWith(color: theme.primaryColor)),
      ),
      startChild: TimelineChild(
        child: Text(DateFormat('dd-MM-yyyy').format(date), style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class IconIndicator extends StatelessWidget {
  final String iconName;
  final Color color;

  const IconIndicator({@required this.iconName, this.color, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: color ?? Theme.of(context).accentColor),
      child: Center(
        child: Icon(MdiIcons.fromString(iconName), color: Colors.white),
      ),
    );
  }
}

class TimelineChild extends StatelessWidget {
  final Widget child;

  const TimelineChild({Key key, this.child}) : super(key: key);

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
