import 'package:flutter/material.dart';

class FoodSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onScanBarcode;
  final String? barcodeTooltip;

  const FoodSearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.focusNode,
    this.onScanBarcode,
    this.barcodeTooltip,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : onScanBarcode == null
              ? null
              : IconButton(
                  tooltip: barcodeTooltip,
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  onPressed: onScanBarcode,
                ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
