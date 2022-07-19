import 'package:flutter/material.dart';

class DesignerAddButton extends StatelessWidget {
  final Widget label;
  final void Function() add;

  const DesignerAddButton({required this.label, required this.add, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FloatingActionButton.extended(
          onPressed: add,
          label: label,
          icon: const Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}
