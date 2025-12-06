import 'package:flutter/material.dart';
import 'package:studyu_designer_v2/features/dashboard/studies_filter/widgets/filter_item.dart';
import 'package:studyu_designer_v2/localization/app_localizations.dart';

class DateRangeFilter extends StatelessWidget {
  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime?> onStartChanged;
  final ValueChanged<DateTime?> onEndChanged;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  const DateRangeFilter({
    required this.start,
    required this.end,
    required this.onStartChanged,
    required this.onEndChanged,
    required this.isExpanded,
    required this.onExpansionChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasValue = start != null || end != null;
    return FilterItem(
      keyName:
          "Created Date", // Keep key internal or localize if used for tracking
      title: AppLocalizations.of(context)!.filter_field_created_date,
      isActive: hasValue,
      isInitiallyExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      onReset: () {
        onStartChanged(null);
        onEndChanged(null);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: start ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) onStartChanged(date);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.filter_date_from,
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    child: Text(start?.toString().split(' ')[0] ?? ''),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: end ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) onEndChanged(date);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.filter_date_to,
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    child: Text(end?.toString().split(' ')[0] ?? ''),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
