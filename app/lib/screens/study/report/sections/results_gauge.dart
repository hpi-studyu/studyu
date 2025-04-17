import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';
import 'package:statistics/statistics.dart';

class ColorfulGaugesWidget extends StatelessWidget {
  final String nameInterventionA;
  final String nameInterventionB;
  final num meanInterventionA;
  final num meanInterventionB;

  ColorfulGaugesWidget(
    List<num> valuesInterventionA,
    List<num> valuesInterventionB,
    this.nameInterventionA,
    this.nameInterventionB, {
    super.key,
  })  : meanInterventionA = valuesInterventionA.mean,
        meanInterventionB = valuesInterventionB.mean;

  @override
  Widget build(BuildContext context) {
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
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: createColorfulGauge(
                    0,
                    10,
                    meanInterventionA,
                    nameInterventionA,
                  ), // min, max, value
                ),
              ),
            ],
          ),
        ),
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
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: createColorfulGauge(
                    0,
                    10,
                    meanInterventionB,
                    nameInterventionB,
                  ), // min, max, value
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createColorfulGauge(
    double min,
    double max,
    num value,
    String nameIntervention,
  ) {
    const Color gaugeBackgroundColor = Color(0xFFDFE2EC);

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedRadialGauge(
          duration: const Duration(seconds: 1),
          curve: Curves.elasticOut,
          radius: 100,
          value: value.toDouble(),
          axis: GaugeAxis(
            min: min,
            max: max,
            degrees: 240, // Set to 240 degrees for a 3/4 circular gauge
            style: const GaugeAxisStyle(
              background: gaugeBackgroundColor,
              segmentSpacing: 4,
            ),
            pointer: const GaugePointer.needle(
              width: 10,
              height: 50,
              borderRadius: 8,
              color: Color(0xFF193663),
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
          ),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(
                  text: '/10',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
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
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ColorlessGaugesWidget extends StatelessWidget {
  final String nameInterventionA;
  final String nameInterventionB;
  final num meanInterventionA;
  final num meanInterventionB;

  ColorlessGaugesWidget(
    List<num> valuesInterventionA,
    List<num> valuesInterventionB,
    this.nameInterventionA,
    this.nameInterventionB, {
    super.key,
  })  : meanInterventionA = valuesInterventionA.mean,
        meanInterventionB = valuesInterventionB.mean;

  @override
  Widget build(BuildContext context) {
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
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: createColorlessGauge(
                    0,
                    10,
                    meanInterventionA,
                    nameInterventionA,
                  ), // min, max, value
                ),
              ),
            ],
          ),
        ),
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
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: createColorlessGauge(
                    0,
                    10,
                    meanInterventionB,
                    nameInterventionB,
                  ), // min, max, value
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget createColorlessGauge(
    double min,
    double max,
    num value,
    String nameIntervention,
  ) {
    const Color gaugeBackgroundColor = Color(0xFFDFE2EC);

    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedRadialGauge(
          duration: const Duration(seconds: 1),
          curve: Curves.elasticOut,
          radius: 100,
          value: value.toDouble(),
          axis: GaugeAxis(
            min: min,
            max: max,
            degrees: 240, // Set to 240 degrees for a 3/4 circular gauge
            style: const GaugeAxisStyle(
              background: gaugeBackgroundColor,
              segmentSpacing: 4,
            ),
            pointer: const GaugePointer.needle(
              width: 10,
              height: 50,
              borderRadius: 8,
              color: Color(0xFF193663),
            ),
          ),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(
                  text: '/10',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
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
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MergedGaugesWidget extends StatelessWidget {
  final String nameInterventionA;
  final String nameInterventionB;
  final num meanInterventionA;
  final num meanInterventionB;
  final bool showColors;

  MergedGaugesWidget(
    this.nameInterventionA,
    this.nameInterventionB,
    List<num> valuesInterventionA,
    List<num> valuesInterventionB, {
    this.showColors = true,
    super.key,
  })  : meanInterventionA = valuesInterventionA.mean,
        meanInterventionB = valuesInterventionB.mean;

  @override
  Widget build(BuildContext context) {
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
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: createGauge(
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
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: createGauge(
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
    double min,
    double max,
    num value,
    String nameIntervention,
  ) {
    const Color gaugeBackgroundColor = Color(0xFFDFE2EC);

    // Create a gauge axis based on whether colors should be shown
    GaugeAxis gaugeAxis;

    if (showColors) {
      gaugeAxis = GaugeAxis(
        min: min,
        max: max,
        degrees: 240, // Set to 240 degrees for a 3/4 circular gauge
        style: const GaugeAxisStyle(
          background: gaugeBackgroundColor,
          segmentSpacing: 4,
        ),
        pointer: const GaugePointer.needle(
          width: 10,
          height: 50,
          borderRadius: 8,
          color: Color(0xFF193663),
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
        style: const GaugeAxisStyle(
          background: gaugeBackgroundColor,
          segmentSpacing: 4,
        ),
        pointer: const GaugePointer.needle(
          width: 10,
          height: 50,
          borderRadius: 8,
          color: Color(0xFF193663),
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
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const TextSpan(
                  text: '/10',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
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
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
