import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:statistics/statistics.dart';
import 'package:studyu_app/spacing.dart';

class GaugesWidget extends StatelessWidget {
  final String nameInterventionA;
  final String nameInterventionB;
  final num meanInterventionA;
  final num meanInterventionB;
  final bool showColors;

  GaugesWidget(
    this.nameInterventionA,
    this.nameInterventionB,
    List<num> valuesInterventionA,
    List<num> valuesInterventionB, {
    this.showColors = true,
    super.key,
  }) : meanInterventionA = valuesInterventionA.mean,
       meanInterventionB = valuesInterventionB.mean;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(StudyUSpacing.space2),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: createGauge(
                    context,
                    0,
                    10,
                    meanInterventionA,
                    nameInterventionA,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(StudyUSpacing.space2),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: createGauge(
                    context,
                    0,
                    10,
                    meanInterventionB,
                    nameInterventionB,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createGauge(
    BuildContext context,
    double min,
    double max,
    num value,
    String nameIntervention,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final gaugeBackgroundColor = colorScheme.surfaceContainerHighest;
    final needleColor = colorScheme.onSurface;

    // Create a gauge axis based on whether colors should be shown
    GaugeAxis gaugeAxis;

    if (showColors) {
      gaugeAxis = GaugeAxis(
        min: min,
        max: max,
        degrees: 240, // Set to 240 degrees for a 3/4 circular gauge
        style: GaugeAxisStyle(
          background: gaugeBackgroundColor,
          segmentSpacing: 4,
        ),
        pointer: GaugePointer.needle(
          width: 10,
          height: 50,
          borderRadius: 8,
          color: needleColor,
        ),
        progressBar: null, // Disable the progress bar
        segments: [
          GaugeSegment(from: 0, to: 1, color: Colors.red[900]!),
          const GaugeSegment(from: 1, to: 2, color: Colors.red),
          GaugeSegment(from: 2, to: 3, color: Colors.orange[900]!),
          const GaugeSegment(from: 3, to: 4, color: Colors.orange),
          const GaugeSegment(from: 4, to: 5, color: Colors.yellow),
          const GaugeSegment(from: 5, to: 6, color: Colors.lightGreen),
          GaugeSegment(from: 6, to: 7, color: Colors.green[600]!),
          GaugeSegment(from: 7, to: 8, color: Colors.green[700]!),
          GaugeSegment(from: 8, to: 9, color: Colors.green[800]!),
          GaugeSegment(from: 9, to: 10, color: Colors.green[900]!),
        ],
      );
    } else {
      gaugeAxis = GaugeAxis(
        min: min,
        max: max,
        degrees: 240, // Set to 240 degrees for a 3/4 circular gauge
        style: GaugeAxisStyle(
          background: gaugeBackgroundColor,
          segmentSpacing: 4,
        ),
        pointer: GaugePointer.needle(
          width: 10,
          height: 50,
          borderRadius: 8,
          color: needleColor,
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedRadialGauge(
          duration: const Duration(seconds: 1),
          curve: Curves.elasticOut,
          radius: 100,
          value: value.toDouble(),
          axis: gaugeAxis,
        ),
        // Text placed inside the gauge box
        Positioned(
          bottom:
              30, // Position text inside the gauge without overlapping the needle
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: value.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: '/10',
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          child: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: nameIntervention,
                  style: TextStyle(fontSize: 15, color: colorScheme.onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
