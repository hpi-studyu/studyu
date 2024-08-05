import 'package:flutter/material.dart';

// Row 6: Descriptive Statistics
class DescriptiveStatisticsWidget extends StatelessWidget {

  const DescriptiveStatisticsWidget({super.key});

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
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'p-value: 0.01\nLevel of significance: α = 0.05',
                    style: TextStyle(fontSize: 8, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTable() {
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
          0: FixedColumnWidth(65),
          1: FixedColumnWidth(65),
          2: FixedColumnWidth(50),
          3: FixedColumnWidth(50),
          4: FixedColumnWidth(50),
          5: FixedColumnWidth(65),
        },
        children: [
          _buildTableRow(
            ['Intervention', 'Observations', 'Average', 'Min', 'Max', 'Variance'],
            isHeader: true,
          ),
          _buildTableRow(['Tea', '14', '5.0', '4', '3', '1.2']),
          _buildTableRow(['No Tea', '14', '7.5', '8', '6', '2']),
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
          fontSize: isHeader ? 8 : 8,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.black : Colors.grey[800],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
