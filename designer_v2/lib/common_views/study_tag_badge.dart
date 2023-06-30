import 'package:flutter/material.dart';
import 'package:studyu_core/core.dart';

class StudyTagBadge<T> extends StatelessWidget {
  final StudyTag tag;
  final VoidCallback? onRemove;

  const StudyTagBadge({required this.tag, this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(tag.name),
      deleteButtonTooltipMessage: '',
      backgroundColor: Color(tag.color ?? Colors.grey.value),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      deleteIcon: const Icon(Icons.close),
      onDeleted: onRemove,
    );
  }
}
