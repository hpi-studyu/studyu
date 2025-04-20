import 'package:flutter/material.dart';
import 'package:statistics/statistics.dart';
import 'package:studyu_app/l10n/app_localizations.dart';
import 'package:studyu_app/screens/study/report/sections/t_test.dart';
import 'package:studyu_core/core.dart';

class TextualSummaryWidget extends StatelessWidget {
  final List<num> valuesInterventionA;
  final List<num> valuesInterventionB;
  final String nameInterventionA;
  final String nameInterventionB;
  final StudySubject subject;
  final ReportSection section;

  const TextualSummaryWidget(
    this.nameInterventionA,
    this.nameInterventionB,
    this.valuesInterventionA,
    this.valuesInterventionB,
    this.subject,
    this.section, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (valuesInterventionA.length < 2 || valuesInterventionB.length < 2) {
      return Text(
        "no data",
        style: const TextStyle(fontStyle: FontStyle.italic),
      );
    }
    // Create t-test with the refactored class
    final tTest = TTest(valuesInterventionA, valuesInterventionB);

    // Get significant difference result (now synchronous)
    final isDifferent = tTest.isSignificantlyDifferent();

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: getTextualSummaryRich(context, isDifferent),
                        ),
                        IconButton(
                          icon: const Icon(Icons.info_outline),
                          tooltip: 'Significance level and p-value',
                          onPressed: () =>
                              _showStatisticalInfoDialog(context, tTest),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showStatisticalInfoDialog(BuildContext context, TTest tTest) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Statistical Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The outcome is based on the following values:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Level of significance α = 0.05',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'P-value: ${tTest.pValue.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                't-statistic: ${tTest.tStatistic.toStringAsFixed(4)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Degrees of freedom: ${tTest.degreesOfFreedom.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  RichText getTextualSummaryRich(BuildContext context, bool isDifferent) {
    final loc = AppLocalizations.of(context)!;
    List<TextSpan> spans;

    if (isDifferent) {
      final isHigher = valuesInterventionA.mean > valuesInterventionB.mean;

      spans = [
        TextSpan(text: loc.text_summary_section_prefix_higher),
        TextSpan(
          text: section.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(
          text: isHigher
              ? loc.text_summary_section_was_higher
              : loc.text_summary_section_was_lower,
        ),
        TextSpan(
          text: nameInterventionA,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        TextSpan(text: loc.text_summary_section_compared_to),
        TextSpan(
          text: nameInterventionB,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const TextSpan(text: "."),
      ];
    } else {
      spans = [
        TextSpan(text: loc.text_summary_section_no_evidence),
        TextSpan(
          text: section.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        TextSpan(text: loc.text_summary_section_between),
        TextSpan(
          text: nameInterventionA,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        TextSpan(text: loc.text_summary_section_and),
        TextSpan(
          text: nameInterventionB,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        const TextSpan(text: "."),
      ];
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black),
        children: spans,
      ),
    );
  }
}
