import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rainbow_color/rainbow_color.dart';
import 'package:studyou_core/models/models.dart';

import '../../../models/app_state.dart';
import '../../../util/localization.dart';

class ReportDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: Icon(MdiIcons.download),
              // TODO add pdf download
              onPressed: () => null,
            ),
          ],
        ),
        body: Consumer<AppModel>(
          builder: (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReportModule(ReportGeneralDetailsModule(value.reportStudy)),
              ReportModule(ReportPerformanceModule(value.reportStudy)),
              ReportModule(ReportOutcomeModule(value.reportStudy)),
            ],
          ),
        ),
      );
}

class ReportModule extends StatelessWidget {
  final ReportModuleContent module;

  const ReportModule(this.module);

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: module,
          ),
        ),
      );
}

abstract class ReportModuleContent extends StatelessWidget {
  final StudyInstance instance;

  const ReportModuleContent(this.instance);
}

class ReportGeneralDetailsModule extends ReportModuleContent {
  const ReportGeneralDetailsModule(StudyInstance instance) : super(instance);

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(instance.description),
        ],
      );
}

class ReportPerformanceModule extends ReportModuleContent {
  const ReportPerformanceModule(StudyInstance instance) : super(instance);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
                '${Nof1Localizations.of(context).translate('current_power_level')}: ${getPowerLevelDescription()}'),
          ),
          PerformanceBar(
            progress: 0.4,
            minimum: 0.6,
          ),
        ],
      );

  String getPowerLevelDescription() {
    // TODO add useful power level wording
    return 'OVER 9000';
  }
}

class PerformanceBar extends StatelessWidget {
  final double progress;
  final double minimum;

  const PerformanceBar({@required this.progress, this.minimum, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final rainbow = Rainbow(spectrum: [Colors.red, Colors.yellow, Colors.green], rangeStart: 0, rangeEnd: 1);
    final fullSpectrum = List<double>.generate(3, (index) => index * 0.5)
        .map<Color>((index) => rainbow[index].withOpacity(0.4))
        .toList();
    final colorSamples =
        List<double>.generate(11, (index) => index * 0.1 * progress).map<Color>((index) => rainbow[index]).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: fullSpectrum,
                    ),
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(width: 2, color: Colors.grey[600])),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: colorSamples,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (minimum != null && minimum >= 0 && minimum <= 1)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FractionallySizedBox(
                widthFactor: minimum,
                child: Container(
                  height: 15,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(width: 2, color: Colors.grey[600])),
                  ),
                ),
              ),
              // TODO fix text positioning
              Text('min'),
            ],
          ),
      ],
    );
  }
}

class ReportOutcomeModule extends ReportModuleContent {
  const ReportOutcomeModule(StudyInstance instance) : super(instance);

  @override
  Widget build(BuildContext context) => Card();
}
