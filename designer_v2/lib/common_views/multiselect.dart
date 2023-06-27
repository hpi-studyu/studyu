import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';

// todo can this be stateless?
class MultiSelectWidget<T> extends StatefulWidget {
  const MultiSelectWidget({
    required this.items,
    required this.selectedOptions,
    required this.onConfirm,
    super.key,
  });

  final List<MultiSelectItem<T>> items;
  final List<MultiSelectItem<T>> selectedOptions;
  final void Function(List<MultiSelectItem<T>> selectedItems) onConfirm;
  final int _maxSelection = 3; // Maximum number of selections

  @override
  MultiSelectWidgetState<T> createState() => MultiSelectWidgetState<T>();
}

class MultiSelectWidgetState<T> extends State<MultiSelectWidget<T>> {
  late List<MultiSelectItem<T>> _selectedOptions;

  void _showSelectionDialog() {
    /*
     return AlertDialog(
                    titlePadding: const EdgeInsets.all(0.0),
                    contentPadding: const EdgeInsets.all(0.0),
                    content: SingleChildScrollView(
     */
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StandardDialog(
          titleText: 'Selected Options',
          body: SizedBox(
            width: 300,
            height: 300,
            child: MultiSelectDialogContent<T>(items: widget.items, selectedOptions: _selectedOptions, maxSelection: widget._maxSelection),
          ),
          actionButtons: [
            ElevatedButton(
              onPressed: () {
                widget.onConfirm(_selectedOptions);
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectedOptions = widget.selectedOptions;
    return Container(
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          //Text(_selectedOptions.toString()),
          ElevatedButton(
            onPressed: _showSelectionDialog,
            child: const Text('Modify tags'),
          ),
        ],
      ),
    );
  }
}

class MultiSelectDialogContent<T> extends StatefulWidget {
  const MultiSelectDialogContent({
    required this.items,
    required this.selectedOptions,
    this.maxSelection = 10,
    super.key,
  });

  final List<MultiSelectItem<T>> items;
  final List<MultiSelectItem<T>> selectedOptions;
  final int maxSelection;

  @override
  MultiSelectDialogContentState createState() => MultiSelectDialogContentState();
}

class MultiSelectDialogContentState extends State<MultiSelectDialogContent> {
  bool _isSelected(MultiSelectItem option) {
    return widget.selectedOptions.contains(option);
  }

  void _toggleOption(MultiSelectItem option) {
    setState(() {
      if (_isSelected(option)) {
        widget.selectedOptions.remove(option);
      } else {
        if (widget.selectedOptions.length < widget.maxSelection) {
          widget.selectedOptions.add(option);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    /*
    child: SizedBox(
            width: width ?? dialogWidth,
            height: height,
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  padding.left,
                  padding.top,
                  padding.right,
                  padding.bottom,
                ),
                child:
     */
    return SizedBox(
      child: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final option = widget.items[index];
          final isSelected = _isSelected(option);
          return ListTile(
            onTap: () => _toggleOption(option),
            title: Text(option.name),
            leading: isSelected
                ? const Icon(Icons.check_box)
                : const Icon(Icons.check_box_outline_blank),
          );
        },
      ),
    );
  }
}

class MultiSelectItem<T> {
  MultiSelectItem({
    required this.name,
    required this.value
  });

  String name;
  T value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiSelectItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => name.hashCode ^ value.hashCode;
}
