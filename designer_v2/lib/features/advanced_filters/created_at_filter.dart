import 'package:flutter/material.dart';

enum CreatedAtPreset { any, last7d, last30d, last90d, last180d, customRange }

class CreatedAtFilter extends StatefulWidget {
  final CreatedAtPreset? initial;
  final void Function(CreatedAtPreset value) onChanged;

  const CreatedAtFilter({
    super.key,
    this.initial,
    required this.onChanged,
  });

  @override
  State<CreatedAtFilter> createState() => _CreatedAtFilterState();
}

class _CreatedAtFilterState extends State<CreatedAtFilter> {
  late CreatedAtPreset _value;

  static const _items = <DropdownMenuItem<CreatedAtPreset>>[
    DropdownMenuItem(value: CreatedAtPreset.any,        child: Text('Any time')),
    DropdownMenuItem(value: CreatedAtPreset.last7d,     child: Text('Last 7 days')),
    DropdownMenuItem(value: CreatedAtPreset.last30d,    child: Text('Last 30 days')),
    DropdownMenuItem(value: CreatedAtPreset.last90d,    child: Text('Last 90 days')),
    DropdownMenuItem(value: CreatedAtPreset.last180d,   child: Text('Last 180 days')),
    DropdownMenuItem(value: CreatedAtPreset.customRange,child: Text('Custom range…')),
  ];

  @override
  void initState() {
    super.initState();
    _value = widget.initial ?? CreatedAtPreset.any;
  }

  @override
  Widget build(BuildContext context) {
    final safeValue = _items.any((i) => i.value == _value)
        ? _value
        : CreatedAtPreset.any; // <= assertion guard

    return DropdownButtonFormField<CreatedAtPreset>(
      value: safeValue,
      items: _items,
      decoration: const InputDecoration(labelText: 'Created at'),
      onChanged: (v) {
        if (v == null) return;
        setState(() => _value = v);
        widget.onChanged(v);
        if (v == CreatedAtPreset.customRange) {
          // TODO: open your date-range picker and persist start/end elsewhere
        }
      },
    );
  }
}
