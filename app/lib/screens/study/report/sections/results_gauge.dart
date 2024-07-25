import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

// Row 3:  Gauge title
class GaugeTitleWidget extends StatelessWidget {
  const GaugeTitleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Average Sleep Quality',
        style: TextStyle(fontSize: 16, color: Colors.blueAccent),
      ),
    );
  }
}

// Row 4:  Two gauges
class GaugesWidget extends StatelessWidget {
  const GaugesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                width: 140, // Set the desired width
                height: 140, // Set the desired height
                child: createGauge(0, 10, 10, 5), // min, max, steps, value
              ),
              Text('With Tea', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                width: 140, // Set the desired width
                height: 140, // Set the desired height
                child: createGauge(0, 10, 10, 7.5), // min, max, steps, value
              ),
              Text('Without Tea', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  // Create gauge with min and max values, steps to switch colors, value to point at
  Widget createGauge(double min, double max, int steps, double value) {
    // List of colors
    List<Color> colors = [
      Colors.red[900]!,
      Colors.red[700]!,
      Colors.red[500]!,
      Colors.orange[900]!,
      Colors.orange[700]!,
      Colors.yellow[700]!,
      Colors.yellow[500]!,
      Colors.green[300]!,
      Colors.green[500]!,
      Colors.green[700]!
    ];

    // Create gauge ranges based on steps and the color list
    List<GaugeRange> createRanges() {
      double stepValue = (max - min) / steps;
      return List.generate(steps, (index) {
        double start = min + (index * stepValue);
        double end = start + stepValue;
        return GaugeRange(
          startValue: start,
          endValue: end,
          color: colors[index],
        );
      });
    }

    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: min,
          maximum: max,
          pointers: <GaugePointer>[
            NeedlePointer(
              value: value,
              needleColor: Colors.blue,
              needleEndWidth: 7,
            ),
          ],
          ranges: createRanges(),
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '$value',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    ),
                    TextSpan(
                      text: '/$max',
                      style: const TextStyle(fontSize: 10, color: Colors.blue),
                    ),
                  ],
                ),
              ),
              angle: 90,
              positionFactor: 0.8,
            ),
          ],
        ),
      ],
    );
  }
}
