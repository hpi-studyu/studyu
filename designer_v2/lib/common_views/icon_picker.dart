import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:studyu_designer_v2/common_views/dialog.dart';
import 'package:studyu_designer_v2/common_views/mouse_events.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/typings.dart';

class IconPack {
  static final defaultPack = IconPack.material;

  static final List<IconOption> material = () {
    final List<IconOption> iconOptions = [];

    // TODO: migrate app + designer to standard material icons & remove library
    final iconNames = MdiIcons.getNames();
    for (final iconName in iconNames) {
      final iconData = MdiIcons.fromString(iconName);
      if (iconData != null) {
        iconOptions.add(IconOption(iconName, iconData));
      }
    }

    return iconOptions;
  }();

  static IconOption? resolveIconByName(String? name, {List<IconOption>? iconPack}) {
    iconPack ??= IconPack.defaultPack;
    if (name == null || name.isEmpty) {
      return null;
    }
    return iconPack.firstWhere((element) => element.name == name);
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
  static IconOption fromJson(String json) => IconOption(json);
}

class ReactiveIconPicker extends ReactiveFocusableFormField<IconOption, IconOption> {
  ReactiveIconPicker({
    required iconOptions,
    selectedIconSize = 20.0,
    galleryIconSize = 28.0,
    bool readOnly = false,
    ReactiveFormFieldCallback<IconOption>? onSelect,
    super.formControl,
    super.formControlName,
    super.showErrors,
    super.validationMessages,
    super.focusNode,
    super.key,
  }) : super(builder: (ReactiveFormFieldState<IconOption, IconOption> field) {
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
              });
        });
}

class IconPicker extends StatelessWidget {
  const IconPicker({
    required this.iconOptions,
    this.selectedOption,
    this.selectedIconSize,
    this.galleryIconSize = 28.0,
    this.onSelect,
    this.isDisabled = false,
    this.focusNode,
    super.key,
  });

  final List<IconOption> iconOptions;
  final IconOption? selectedOption;
  final VoidCallbackOn<IconOption>? onSelect;

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
      isDisabled: isDisabled,
      focusNode: focusNode,
    );
  }
}

class IconPickerField extends StatelessWidget {
  const IconPickerField(
      {required this.iconOptions,
      this.selectedOption,
      this.selectedIconSize,
      this.galleryIconSize,
      this.onSelect,
      this.isDisabled = false,
      this.focusNode,
      super.key});

  final List<IconOption> iconOptions;

  final IconOption? selectedOption;
  final double? selectedIconSize;
  final double? galleryIconSize;
  final VoidCallbackOn<IconOption>? onSelect;

  final FocusNode? focusNode;

  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final actualGalleryIconSize = galleryIconSize ?? Theme.of(context).iconTheme.size ?? 24.0;
    final actualSelectedIconSize = selectedIconSize ?? Theme.of(context).iconTheme.size ?? 16.0;

    openIconPicker() => showIconPickerDialog(context,
        iconOptions: iconOptions, galleryIconSize: actualGalleryIconSize, onSelect: onSelect);

    if (selectedOption != null && !selectedOption!.isEmpty) {
      final selectedIcon =
          selectedOption?.icon ?? IconPack.resolveIconByName(selectedOption!.name, iconPack: iconOptions)!.icon;
      return IconButton(
          tooltip: tr.iconpicker_nonempty_prompt,
          splashRadius: actualSelectedIconSize,
          onPressed: (isDisabled) ? null : openIconPicker,
          focusNode: focusNode,
          icon: Icon(selectedIcon, size: actualSelectedIconSize));
    }

    return TextButton(
      onPressed: (isDisabled) ? null : openIconPicker,
      focusNode: focusNode,
      child: Text(tr.iconpicker_empty_prompt),
    );
  }
}

class IconPickerGallery extends StatelessWidget {
  const IconPickerGallery({required this.iconOptions, required this.iconSize, this.onSelect, super.key});

  final List<IconOption> iconOptions;
  final VoidCallbackOn<IconOption>? onSelect;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final List<Widget> iconWidgets = [];
    for (final iconOption in iconOptions) {
      final iconWidget = MouseEventsRegion(
          builder: (context, state) {
            final isHovered = state.contains(MaterialState.hovered);
            return Container(
              color: isHovered ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : null,
              child: Icon(iconOption.icon!, size: iconSize),
            );
          },
          onTap: () => Navigator.pop(context, iconOption));
      iconWidgets.add(iconWidget);
    }

    return GridView.extent(
        primary: false,
        maxCrossAxisExtent: iconSize * 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        //padding: const EdgeInsets.all(12.0),
        children: iconWidgets);
  }
}

Future<void> showIconPickerDialog(
  BuildContext context, {
  required List<IconOption> iconOptions,
  double? galleryIconSize,
  VoidCallbackOn<IconOption>? onSelect,
  minWidth = 300,
  minHeight = 300,
}) async {
  IconOption? iconPicked = await showDialog(
    context: context,
    builder: (BuildContext context) {
      final theme = Theme.of(context);
      final dialogWidth = MediaQuery.of(context).size.width * 0.4;
      final dialogHeight = MediaQuery.of(context).size.height * 0.4;

      return StandardDialog(
          body: SizedBox(
            width: max(dialogWidth, minWidth),
            height: max(dialogHeight, minHeight),
            child: IconPickerGallery(iconOptions: iconOptions, iconSize: galleryIconSize ?? 48.0),
          ),
          title: SelectableText(
            tr.iconpicker_dialog_title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.normal,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ));
    },
  );

  if (iconPicked != null && onSelect != null) {
    onSelect(iconPicked);
  }
}
