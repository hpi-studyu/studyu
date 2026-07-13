import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

class InviteCodeFilterButton extends StatefulWidget {
  const InviteCodeFilterButton({
    required this.filters,
    required this.onApply,
    super.key,
  });

  final InviteCodeFilters filters;
  final ValueChanged<InviteCodeFilters> onApply;

  @override
  State<InviteCodeFilterButton> createState() => _InviteCodeFilterButtonState();
}

class _InviteCodeFilterButtonState extends State<InviteCodeFilterButton> {
  late InviteCodeFilters _draft;
  late final TextEditingController _enrolledMinController;
  late final TextEditingController _enrolledMaxController;

  @override
  void initState() {
    super.initState();
    _enrolledMinController = TextEditingController();
    _enrolledMaxController = TextEditingController();
    _resetDraft();
  }

  @override
  void dispose() {
    _enrolledMinController.dispose();
    _enrolledMaxController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant InviteCodeFilterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters != widget.filters) {
      _resetDraft();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeCount = widget.filters.activeCount;
    final isActive = activeCount > 0;

    return MenuAnchor(
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        side: const WidgetStatePropertyAll(BorderSide.none),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      menuChildren: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: 360,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.6,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filter invite codes'.hardcoded,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<InviteCodeEnrolledFilter>(
                      initialValue: _draft.enrolled,
                      decoration: const InputDecoration(
                        labelText: 'Enrolled status',
                      ),
                      items: InviteCodeEnrolledFilter.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_enrolledLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(
                          () => _draft = _draft.copyWith(enrolled: value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _enrolledMinController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Enrolled min',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _enrolledMaxController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Enrolled max',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<InviteCodeInterventionFilter>(
                      initialValue: _draft.intervention,
                      decoration: const InputDecoration(
                        labelText: 'Intervention assignment',
                      ),
                      items: InviteCodeInterventionFilter.values
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(_interventionLabel(value)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(
                          () => _draft = _draft.copyWith(intervention: value),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DateRangeRow(
                      title: 'Created'.hardcoded,
                      from: _draft.createdFrom,
                      to: _draft.createdTo,
                      onPickFrom: () => _pickDate(
                        initial: _draft.createdFrom,
                        onSelected: (value) => setState(
                          () => _draft = _draft.copyWith(createdFrom: value),
                        ),
                      ),
                      onPickTo: () => _pickDate(
                        initial: _draft.createdTo,
                        onSelected: (value) => setState(
                          () => _draft = _draft.copyWith(createdTo: value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _DateRangeRow(
                      title: 'Updated'.hardcoded,
                      from: _draft.updatedFrom,
                      to: _draft.updatedTo,
                      onPickFrom: () => _pickDate(
                        initial: _draft.updatedFrom,
                        onSelected: (value) => setState(
                          () => _draft = _draft.copyWith(updatedFrom: value),
                        ),
                      ),
                      onPickTo: () => _pickDate(
                        initial: _draft.updatedTo,
                        onSelected: (value) => setState(
                          () => _draft = _draft.copyWith(updatedTo: value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {
                            _resetDraft(const InviteCodeFilters());
                            widget.onApply(const InviteCodeFilters());
                          },
                          child: Text('Clear all'.hardcoded),
                        ),
                        const Spacer(),
                        FilledButton(
                          onPressed: () {
                            final applied = _draft
                                .copyWith(
                                  enrolledMin: _parseInt(
                                    _enrolledMinController.text,
                                  ),
                                  clearEnrolledMin: _enrolledMinController.text
                                      .trim()
                                      .isEmpty,
                                  enrolledMax: _parseInt(
                                    _enrolledMaxController.text,
                                  ),
                                  clearEnrolledMax: _enrolledMaxController.text
                                      .trim()
                                      .isEmpty,
                                )
                                .normalized();
                            widget.onApply(applied);
                          },
                          child: Text('Apply'.hardcoded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
      builder: (context, controller, child) {
        return OutlinedButton.icon(
          icon: Icon(
            Icons.filter_list_rounded,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          label: Text(
            isActive ? 'Filter ($activeCount)'.hardcoded : 'Filter'.hardcoded,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: isActive
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
                : theme.colorScheme.surface,
            side: BorderSide(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : theme.colorScheme.outlineVariant,
            ),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            minimumSize: const Size(0, 40),
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
              return;
            }
            _resetDraft();
            controller.open();
          },
        );
      },
    );
  }

  Future<void> _pickDate({
    required DateTime? initial,
    required ValueChanged<DateTime> onSelected,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      initialDate: initial ?? now,
    );
    if (picked != null) {
      onSelected(DateTime(picked.year, picked.month, picked.day));
    }
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  void _resetDraft([InviteCodeFilters? filters]) {
    _draft = (filters ?? widget.filters).normalized();
    _enrolledMinController.text = _draft.enrolledMin?.toString() ?? '';
    _enrolledMaxController.text = _draft.enrolledMax?.toString() ?? '';
    if (mounted) {
      setState(() {});
    }
  }

  String _enrolledLabel(InviteCodeEnrolledFilter value) {
    return switch (value) {
      InviteCodeEnrolledFilter.all => 'All'.hardcoded,
      InviteCodeEnrolledFilter.unused => 'Unused'.hardcoded,
      InviteCodeEnrolledFilter.used => 'Used'.hardcoded,
    };
  }

  String _interventionLabel(InviteCodeInterventionFilter value) {
    return switch (value) {
      InviteCodeInterventionFilter.all => 'All'.hardcoded,
      InviteCodeInterventionFilter.defaultAssignment => 'Default'.hardcoded,
      InviteCodeInterventionFilter.interventionA => 'Intervention A'.hardcoded,
      InviteCodeInterventionFilter.interventionB => 'Intervention B'.hardcoded,
    };
  }
}

class _DateRangeRow extends StatelessWidget {
  const _DateRangeRow({
    required this.title,
    required this.from,
    required this.to,
    required this.onPickFrom,
    required this.onPickTo,
  });

  final String title;
  final DateTime? from;
  final DateTime? to;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    String format(DateTime? value, String emptyLabel) {
      if (value == null) return emptyLabel;
      return localizations.formatShortDate(value);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onPickFrom,
                child: Text(format(from, 'From'.hardcoded)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onPickTo,
                child: Text(format(to, 'To'.hardcoded)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
