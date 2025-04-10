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
  bool _isLoading = true;
  late final ReportUtilities _reportUtilities;
  late final Map<String, List<num>> _interventionValues;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _reportUtilities = ReportUtilities(widget.subject);

    final results =
        widget.section.resultProperty?.retrieveFromResults(widget.subject);

    if (results == null || results.isEmpty) {
      _interventionValues = {};
    } else {
      final diagramDatums =
          _reportUtilities.convertToDiagramData(results).toList();
      _interventionValues =
          _reportUtilities.getInterventionGroups(diagramDatums);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_interventionValues.keys.length < 2) {
      return const SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Text("Not enough data yet to provide summary"), //TODO: translation
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.section.title != null)
          Text(
            widget.section.title!,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        const SizedBox(height: 4),
        TextualSummaryWidget(
          _interventionValues.keys.first,
          _interventionValues.keys.elementAt(1),
          _interventionValues[_interventionValues.keys.first]!,
          _interventionValues[_interventionValues.keys.elementAt(1)]!,
          widget.subject,
          widget.section,
        ),
      ],
    );
  }
}
