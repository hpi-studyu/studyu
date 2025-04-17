import 'package:flutter/material.dart';
import 'package:studyu_app/screens/study/report/report_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/results_descriptive_statistics.dart';
import 'package:studyu_app/screens/study/report/util/report_utilities.dart';
import 'package:studyu_core/core.dart';

class DescriptiveStatsSectionWidget extends ReportSectionWidget {
  final DescriptiveStatsSection section;

  const DescriptiveStatsSectionWidget(super.subject, this.section, {super.key});

  @override
  Widget build(BuildContext context) {
    return _DescriptiveStatsSectionStatefulWidget(subject, section);
  }
}

class _DescriptiveStatsSectionStatefulWidget extends StatefulWidget {
  final StudySubject subject;
  final DescriptiveStatsSection section;

  const _DescriptiveStatsSectionStatefulWidget(this.subject, this.section);

  @override
  State<_DescriptiveStatsSectionStatefulWidget> createState() =>
      _DescriptiveStatsSectionState();
}

class _DescriptiveStatsSectionState
    extends State<_DescriptiveStatsSectionStatefulWidget> {
  bool _isLoading = true;
  bool showColorlessGauges = false;

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

    final interventionA = _interventionValues.entries.firstOrNull;
    final interventionB = _interventionValues.entries.elementAtOrNull(1);

    if (interventionA == null) {
      return const SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("No data available"),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DescriptiveStatisticsWidget(
          valuesInterventionA: interventionA.value,
          nameInterventionA:
              _reportUtilities.getInterventionName(interventionA.key),
          valuesInterventionB: interventionB?.value ?? const <num>[],
          nameInterventionB: interventionB?.key != null
              ? _reportUtilities.getInterventionName(interventionB!.key)
              : 'No data available', //TODO: translation
          subject: widget.subject,
        ),
      ],
    );
  }
}
