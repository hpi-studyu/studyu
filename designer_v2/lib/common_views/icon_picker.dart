import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/common_views/search.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/typings.dart';
import 'package:studyu_flutter_common/studyu_flutter_common.dart';

class IconPack {
  static final defaultPack = IconPack.material;

  static final List<IconOption> material = () {
    final List<IconOption> iconOptions = [];

    // TODO: migrate app + designer to standard material icons & remove library
    final iconNames = MdiIconsHelper.getNames();
    for (final iconName in iconNames) {
      final iconData = MdiIconsHelper.fromString(iconName);
      if (iconData != null) {
        iconOptions.add(IconOption(iconName, iconData));
      }
    }

    return iconOptions;
  }();

  static IconOption? resolveIconByName(
    String? name, {
    List<IconOption>? iconPack,
  }) {
    iconPack ??= IconPack.defaultPack;
    if (name == null || name.isEmpty) {
      return null;
    }
    for (final iconOption in iconPack) {
      if (iconOption.name == name) {
        return iconOption;
      }
    }
    return null;
  }

  static List<IconOption> filterByQuery(
    List<IconOption> iconOptions,
    String query,
  ) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return iconOptions;
    }

    return iconOptions
        .where(
          (iconOption) =>
              iconOption.name.toLowerCase().contains(normalizedQuery),
        )
        .toList(growable: false);
  }
}

class IconOption extends Equatable {
  const IconOption(this.name, [this.icon]);

  final String name;
  final IconData? icon;

  bool get isEmpty => name == '';

  @override
  List<Object?> get props => [name];

  String toJson() => name;
  IconOption fromJson(String json) => IconOption(json);
}

class ReactiveIconPicker
    extends ReactiveFocusableFormField<IconOption, IconOption> {
  ReactiveIconPicker({
    required List<IconOption> iconOptions,
    double? selectedIconSize = 20.0,
    double? galleryIconSize = 28.0,
    bool readOnly = false,
    ReactiveFormFieldCallback<IconOption>? onSelect,
    VoidCallback? onClear,
    super.formControl,
    super.formControlName,
    super.showErrors,
    super.validationMessages,
    super.focusNode,
    super.key,
  }) : super(
         builder: (ReactiveFormFieldState<IconOption, IconOption> field) {
           // Unsupported: showErrors, validationMessages
           final isDisabled = readOnly || field.control.disabled;

           return IconPicker(
             iconOptions: iconOptions,
             isDisabled: isDisabled,
             focusNode: focusNode,
             selectedOption: field.value,
             galleryIconSize: galleryIconSize,
             selectedIconSize: selectedIconSize,
             onSelect: (iconOption) {
               if (isDisabled) return;
               field.didChange(iconOption);
               onSelect?.call(field.control);
             },
             onClear: () {
               if (isDisabled) return;
               field.didChange(null);
               onClear?.call();
             },
           );
         },
       );
}

class IconPicker extends StatelessWidget {
  const IconPicker({
    required this.iconOptions,
    this.selectedOption,
    this.selectedIconSize,
    this.galleryIconSize = 28.0,
    this.onSelect,
    this.onClear,
    this.isDisabled = false,
    this.focusNode,
    super.key,
  });

  final List<IconOption> iconOptions;
  final IconOption? selectedOption;
  final VoidCallbackOn<IconOption>? onSelect;
  final VoidCallback? onClear;

  final double? galleryIconSize;
  final double? selectedIconSize;

  final FocusNode? focusNode;

  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    return IconPickerField(
      iconOptions: iconOptions,
      selectedOption: selectedOption,
      selectedIconSize: selectedIconSize,
      galleryIconSize: galleryIconSize,
      onSelect: onSelect,
      onClear: onClear,
      isDisabled: isDisabled,
      focusNode: focusNode,
    );
  }
}

class IconPickerField extends StatelessWidget {
  static const _triggerHeight = 40.0;

  const IconPickerField({
    required this.iconOptions,
    this.selectedOption,
    this.selectedIconSize,
    this.galleryIconSize,
    this.onSelect,
    this.onClear,
    this.isDisabled = false,
    this.focusNode,
    super.key,
  });

  final List<IconOption> iconOptions;

  final IconOption? selectedOption;
  final double? selectedIconSize;
  final double? galleryIconSize;
  final VoidCallbackOn<IconOption>? onSelect;
  final VoidCallback? onClear;

  final FocusNode? focusNode;

  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final actualGalleryIconSize =
        galleryIconSize ?? Theme.of(context).iconTheme.size ?? 24.0;
    final actualSelectedIconSize =
        selectedIconSize ?? Theme.of(context).iconTheme.size ?? 16.0;
    final selectedIconDisplaySize = actualSelectedIconSize * 1.15;
    final hasSelection = selectedOption != null && !selectedOption!.isEmpty;
    final selectedIcon =
        selectedOption?.icon ??
        IconPack.resolveIconByName(
          selectedOption?.name,
          iconPack: iconOptions,
        )?.icon;

    Future<void> openIconPicker() async {
      final result = await showIconPickerDialog(
        context,
        iconOptions: iconOptions,
        galleryIconSize: actualGalleryIconSize,
        selectedOption: selectedOption,
      );
      if (result == null) {
        return;
      }
      switch (result.action) {
        case _IconPickerDialogAction.select:
          if (result.selectedOption != null && onSelect != null) {
            onSelect!(result.selectedOption!);
          }
        case _IconPickerDialogAction.remove:
          onClear?.call();
        case _IconPickerDialogAction.cancel:
          break;
      }
    }

    if (hasSelection && selectedIcon != null) {
      final theme = Theme.of(context);

      return SizedBox(
        height: _triggerHeight,
        child: Center(
          child: Tooltip(
            message: tr.iconpicker_nonempty_prompt,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12.0),
                onTap: isDisabled ? null : openIconPicker,
                focusNode: focusNode,
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    width: selectedIconDisplaySize + 20.0,
                    height: selectedIconDisplaySize + 20.0,
                  ),
                  child: Center(
                    child: Icon(
                      selectedIcon,
                      size: selectedIconDisplaySize,
                      color: theme.iconTheme.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: _triggerHeight,
      child: Center(
        child: TextButton(
          onPressed: isDisabled ? null : openIconPicker,
          focusNode: focusNode,
          child: Text(
            hasSelection
                ? tr.iconpicker_nonempty_prompt
                : tr.iconpicker_empty_prompt,
          ),
        ),
      ),
    );
  }
}

class IconPickerGallery extends StatelessWidget {
  const IconPickerGallery({
    required this.iconOptions,
    required this.iconSize,
    this.onSelect,
    super.key,
  });

  final List<IconOption> iconOptions;
  final VoidCallbackOn<IconOption>? onSelect;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    if (iconOptions.isEmpty) {
      return Center(
        child: Text(
          tr.iconpicker_no_results,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final List<Widget> iconWidgets = [];
    for (final iconOption in iconOptions) {
      final iconWidget = MouseEventsRegion(
        builder: (context, state) {
          final isHovered = state.contains(WidgetState.hovered);
          return Container(
            color: isHovered
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                : null,
            child: Tooltip(
              message: iconOption.name,
              child: Icon(iconOption.icon, size: iconSize),
            ),
          );
        },
        onTap: () =>
            Navigator.pop(context, _IconPickerDialogResult.select(iconOption)),
      );
      iconWidgets.add(iconWidget);
    }

    return GridView.extent(
      primary: false,
      maxCrossAxisExtent: iconSize * 2,
      crossAxisSpacing: 4.0,
      mainAxisSpacing: 4.0,
      //padding: const EdgeInsets.all(12.0),
      children: iconWidgets,
    );
  }
}

Future<_IconPickerDialogResult?> showIconPickerDialog(
  BuildContext context, {
  required List<IconOption> iconOptions,
  double? galleryIconSize,
  IconOption? selectedOption,
  double minWidth = 300,
  double minHeight = 300,
}) async {
  final result = await showDialog<_IconPickerDialogResult>(
    context: context,
    builder: (BuildContext context) {
      return _IconPickerDialog(
        iconOptions: iconOptions,
        galleryIconSize: galleryIconSize ?? 48.0,
        selectedOption: selectedOption,
        minWidth: minWidth,
        minHeight: minHeight,
      );
    },
  );
  return result;
}

class _IconPickerDialog extends StatefulWidget {
  const _IconPickerDialog({
    required this.iconOptions,
    required this.galleryIconSize,
    required this.minWidth,
    required this.minHeight,
    this.selectedOption,
  });

  final List<IconOption> iconOptions;
  final double galleryIconSize;
  final IconOption? selectedOption;
  final double minWidth;
  final double minHeight;

  @override
  State<_IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<_IconPickerDialog> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dialogWidth = MediaQuery.of(context).size.width * 0.4;
    final dialogHeight = MediaQuery.of(context).size.height * 0.4;
    final hasSelection =
        widget.selectedOption != null && !widget.selectedOption!.isEmpty;
    final filteredIconOptions = IconPack.filterByQuery(
      widget.iconOptions,
      query,
    );

    return StandardDialog(
      body: SizedBox(
        width: max(dialogWidth, widget.minWidth),
        height: max(dialogHeight, widget.minHeight),
        child: Column(
          children: [
            Search(
              hintText: tr.iconpicker_search_hint,
              onQueryChanged: (value) {
                setState(() {
                  query = value;
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: IconPickerGallery(
                iconOptions: filteredIconOptions,
                iconSize: widget.galleryIconSize,
              ),
            ),
          ],
        ),
      ),
      actionButtons: [
        if (hasSelection)
          TextButton(
            onPressed: () {
              Navigator.pop(context, const _IconPickerDialogResult.remove());
            },
            child: Text(tr.iconpicker_remove_action),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, const _IconPickerDialogResult.cancel());
          },
          child: Text(tr.dialog_cancel),
        ),
      ],
      title: SelectableText(
        tr.iconpicker_dialog_title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.normal,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

enum _IconPickerDialogAction { select, remove, cancel }

class _IconPickerDialogResult {
  const _IconPickerDialogResult.select(this.selectedOption)
    : action = _IconPickerDialogAction.select;
  const _IconPickerDialogResult.remove()
    : action = _IconPickerDialogAction.remove,
      selectedOption = null;
  const _IconPickerDialogResult.cancel()
    : action = _IconPickerDialogAction.cancel,
      selectedOption = null;

  final _IconPickerDialogAction action;
  final IconOption? selectedOption;
}
