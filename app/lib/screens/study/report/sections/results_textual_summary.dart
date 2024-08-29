import 'package:flutter/material.dart';
import 'package:statistics/statistics.dart';
import 'package:studyu_app/screens/study/report/sections/average_section_widget.dart';
import 'package:studyu_app/screens/study/report/sections/t_test.dart';

class TextualSummaryWidget extends AverageSectionWidget {
  final List<num> valuesInterventionA;
  final List<num> valuesInterventionB;
  final String nameInterventionA;
  final String nameInterventionB;

  const TextualSummaryWidget(
    this.valuesInterventionA,
    this.valuesInterventionB,
    this.nameInterventionA,
    this.nameInterventionB,
    super.subject,
    super.section, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Two Sample t-test
    final tTest = TTest(valuesInterventionA, valuesInterventionB);
    // Determine the summary text based on t-test results
    return FutureBuilder<bool>(
      future: tTest.isSignificantlyDifferent(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final summaryText = getTextualSummary(snapshot.data!);
          return Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                child: Text(
                                  summaryText[0],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                tooltip: 'Significance level and p-value',
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text(
                                            'Statistical Information'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'The outcome is based on the following values:',
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Level of significance α = 0.05',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'P-value: 0.7',
                                              style: TextStyle(
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
                                },
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
      },
    );
  }

  // This method returns textual outcomes of a two sample t-test with respect to each of the interventions A and B.
  List<String> getTextualSummary(bool isDifferent) {
    List<String> textualSummaryInterventionAB;
    if (isDifferent) {
      if (valuesInterventionA.mean > valuesInterventionB.mean) {
        textualSummaryInterventionAB = [
          "Your ${section.title} was better during intervention: $nameInterventionA compared to: $nameInterventionB.",
        ];
      } else {
        textualSummaryInterventionAB = [
          "Your ${section.title} was worse during intervention: $nameInterventionA compared to: $nameInterventionB.",
        ];
      }
    } else {
      textualSummaryInterventionAB = [
        "There was no evidence for a difference in ${section.title} between interventions: $nameInterventionA and $nameInterventionB.",
      ];
    }
    return textualSummaryInterventionAB;
  }
}
