import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/report/report_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/results_textual_summary.dart';
import 'package:studyu_app/screens/study/report/util/report_utilities.dart';
import 'package:studyu_core/core.dart';

class TextualSummarySectionWidget extends ReportSectionWidget {
  final TextualSummarySection section;

  const TextualSummarySectionWidget(super.subject, this.section, {super.key});

  @override
  Widget build(BuildContext context) {
    return _TextualSummarySectionStatefulWidget(subject, section);
  }
}

class _TextualSummarySectionStatefulWidget extends StatefulWidget {
  final StudySubject subject;
  final TextualSummarySection section;

  const _TextualSummarySectionStatefulWidget(this.subject, this.section);

  @override
  State<_TextualSummarySectionStatefulWidget> createState() =>
      _TextualSummarySectionState();
}

class _TextualSummarySectionState
    extends State<_TextualSummarySectionStatefulWidget> {
  bool _loading = true;
  late final ReportUtilities reportUtilities;
  late final Map<String, List<num>> interventionValues;

  @override
  void initState() {
    final results =
        widget.section.resultProperty?.retrieveFromResults(widget.subject);

    reportUtilities = ReportUtilities(widget.subject);

    if (results == null) {
      interventionValues = {};

      return;
    }

    if (results.isEmpty) {
      interventionValues = {};
      return;
    }

    final diagramDatums =
        reportUtilities.convertToDiagramData(results).toList();

    interventionValues = reportUtilities.getInterventionGroups(diagramDatums);

    setState(() {
      _loading = false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const CircularProgressIndicator()
        : interventionValues.keys.length < 2
            ? const SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Text("No enough data yet to provide summary"),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.section.title != null)
                    Text(
                      widget.section.title!,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  const SizedBox(height: 4),
                  TextualSummaryWidget(
                    interventionValues.keys.first,
                    interventionValues.keys.elementAt(1),
                    interventionValues[interventionValues.keys.first]!,
                    interventionValues[interventionValues.keys.elementAt(1)]!,
                    widget.subject,
                    widget.section,
                  ),
                ],
              );
  }
}
