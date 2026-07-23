import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studyu_designer_v2/domain/study_invite.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';

const _filterMenuWidth = 360.0;
const _filterMenuBorderRadius = 16.0;
const _filterMenuBorderAlpha = 0.6;
const _filterMenuShadowAlpha = 0.08;
const _filterMenuShadowBlurRadius = 14.0;
const _filterMenuShadowOffsetY = 4.0;
const _filterMenuTopPadding = 5.0;
const _filterMenuPadding = 16.0;
const _filterMenuSectionSpacing = 12.0;
const _filterMenuHeaderSpacing = 16.0;
const _filterButtonCornerRadius = 16.0;
const _filterButtonIconSize = 18.0;
const _filterButtonHorizontalPadding = 14.0;
const _filterButtonVerticalPadding = 10.0;
const _filterButtonMinHeight = 40.0;
const _filterButtonActiveBackgroundAlpha = 0.45;
const _filterButtonActiveBorderAlpha = 0.35;

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
          padding: const EdgeInsets.only(top: _filterMenuTopPadding),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: _filterMenuWidth,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(_filterMenuBorderRadius),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: _filterMenuBorderAlpha,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: _filterMenuShadowAlpha,
                    ),
                    blurRadius: _filterMenuShadowBlurRadius,
                    offset: const Offset(0, _filterMenuShadowOffsetY),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(_filterMenuPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Filter invite codes'.hardcoded,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: _filterMenuHeaderSpacing),
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
                    const SizedBox(height: _filterMenuSectionSpacing),
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
                        const SizedBox(width: _filterMenuSectionSpacing),
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
                    const SizedBox(height: _filterMenuSectionSpacing),
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
                    const SizedBox(height: _filterMenuHeaderSpacing),
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
            size: _filterButtonIconSize,
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
                ? theme.colorScheme.primaryContainer.withValues(
                    alpha: _filterButtonActiveBackgroundAlpha,
                  )
                : theme.colorScheme.surface,
            side: BorderSide(
              color: isActive
                  ? theme.colorScheme.primary.withValues(
                      alpha: _filterButtonActiveBorderAlpha,
                    )
                  : theme.colorScheme.outlineVariant,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_filterButtonCornerRadius),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: _filterButtonHorizontalPadding,
              vertical: _filterButtonVerticalPadding,
            ),
            minimumSize: const Size(0, _filterButtonMinHeight),
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
