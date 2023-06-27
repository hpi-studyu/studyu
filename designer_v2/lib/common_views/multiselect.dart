import 'package:flutter/material.dart';

class MultiSelectWidget extends StatefulWidget {
  const MultiSelectWidget({super.key});

  @override
  _MultiSelectWidgetState createState() => _MultiSelectWidgetState();
}

class _MultiSelectWidgetState extends State<MultiSelectWidget> {
  List<String> _options = [
    'Option 1',
    'Option 2',
    'Option 3',
    'Option 4',
    'Option 5',
  ];
  List<String> _selectedOptions = [];
  final int _maxSelection = 3; // Maximum number of selections

  bool _isSelected(String option) {
    return _selectedOptions.contains(option);
  }

  void _toggleOption(String option) {
    setState(() {
      if (_isSelected(option)) {
        _selectedOptions.remove(option);
      } else {
        if (_selectedOptions.length < _maxSelection) {
          _selectedOptions.add(option);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(16.0),
        width: 500,
        height: 100,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _options.length,
                itemBuilder: (context, index) {
                  final option = _options[index];
                  final isSelected = _isSelected(option);
                  return ListTile(
                    onTap: () => _toggleOption(option),
                    title: Text(option),
                    leading: isSelected
                        ? Icon(Icons.check_box)
                        : Icon(Icons.check_box_outline_blank),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text('Selected Options: ${_selectedOptions.toString()}'),
          ],
        )
    );
  }
}