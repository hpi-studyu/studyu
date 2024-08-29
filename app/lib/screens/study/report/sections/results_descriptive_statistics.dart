import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:statistics/statistics.dart';
import 'package:studyu_app/screens/study/report/sections/average_section_widget.dart';

class DescriptiveStatisticsWidget extends AverageSectionWidget {
  final String nameInterventionA;
  final String nameInterventionB;
  final String averageA;
  final String averageB;
  final int observationsA;
  final int observationsB;
  final String minA;
  final String minB;
  final String maxA;
  final String maxB;
  final String varianceA;
  final String varianceB;
  final int totalInterventionsA;
  final int totalInterventionsB;

  DescriptiveStatisticsWidget(
    List<num> valuesInterventionA,
    List<num> valuesInterventionB,
    this.nameInterventionA,
    this.nameInterventionB,
    super.subject,
    super.section, {
    super.key,
  })  : averageA = valuesInterventionA.isNotEmpty
            ? valuesInterventionA.mean.toStringAsFixed(2)
            : "NONE",
        averageB = valuesInterventionB.isNotEmpty
            ? valuesInterventionB.mean.toStringAsFixed(2)
            : "NONE",
        observationsA = valuesInterventionA.length,
        observationsB = valuesInterventionB.length,
        minA = valuesInterventionA.isNotEmpty
            ? valuesInterventionA.min.toStringAsFixed(2)
            : "NONE",
        minB = valuesInterventionB.isNotEmpty
            ? valuesInterventionB.min.toStringAsFixed(2)
            : "NONE",
        maxA = valuesInterventionA.isNotEmpty
            ? valuesInterventionA.max.toStringAsFixed(2)
            : "NONE",
        maxB = valuesInterventionB.isNotEmpty
            ? valuesInterventionB.max.toStringAsFixed(2)
            : "NONE",
        varianceA = valuesInterventionA.isNotEmpty
            ? pow(valuesInterventionA.standardDeviation, 2).toStringAsFixed(2)
            : "NONE",
        varianceB = valuesInterventionB.isNotEmpty
            ? pow(valuesInterventionB.standardDeviation, 2).toStringAsFixed(2)
            : "NONE",
        totalInterventionsA = subject.study.schedule.phaseDuration *
            subject.study.schedule.numberOfCycles,
        totalInterventionsB = subject.study.schedule.phaseDuration *
            subject.study.schedule.numberOfCycles;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: <Widget>[
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(
                Icons.arrow_drop_up,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              children: [
                _buildStatisticsTable(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTable() {
    final int missingObservationsA = totalInterventionsA - observationsA;
    final int missingObservationsB = totalInterventionsB - observationsB;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Table(
        border: TableBorder.all(color: Colors.grey),
        columnWidths: const {
          0: FixedColumnWidth(120), // Adjust column width if needed
          1: FixedColumnWidth(80),
          2: FixedColumnWidth(80),
        },
        children: [
          _buildTableRow(
            ['Intervention', nameInterventionA, nameInterventionB],
            isHeader: true,
          ),
          _buildTableRow([
            'Observations',
            observationsA.toString(),
            observationsB.toString(),
          ]),
          _buildTableRow(['Average', averageA, averageB]),
          _buildTableRow(['Min', minA, minB]),
          _buildTableRow(['Max', maxA, maxB]),
          _buildTableRow(['Variance', varianceA, varianceB]),
          _buildTableRow([
            'Missing Observations',
            missingObservationsA.toString(),
            missingObservationsB.toString(),
          ]),
        ],
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      children: cells.map((cell) {
        return _buildTableCell(cell, isHeader: isHeader);
      }).toList(),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 15 : 15, //Adjust font size if needed
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.grey[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
