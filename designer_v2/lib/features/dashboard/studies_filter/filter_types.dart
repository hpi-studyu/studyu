import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum FilterLogic { and, or }

enum FilterOperator {
  equals,
  notEquals,
  contains,
  greaterThan,
  lessThan,
  greaterThanOrEqual,
  lessThanOrEqual,
  startsWith,
  endsWith,
  isEmpty,
  isNotEmpty,
  // Date specific
  after,
  before,
  inLast, // e.g. in last 30 days
}

enum StudyProperty {
  title,
  status,
  participation,
  createdAt,
  participantCount,
  activeSubjectCount,
  endedCount,
  missedDays,
  resultSharing,
  registryPublished,
  owner, // derived from isOwner
  editor, // derived from isEditor
}

abstract class FilterElement extends Equatable {
  String get id;
}

class FilterCondition extends FilterElement {
  @override
  final String id;
  final StudyProperty property;
  final FilterOperator operator;
  final dynamic value; // String, num, DateTime, bool, etc.

  FilterCondition({
    String? id,
    required this.property,
    required this.operator,
    this.value,
  }) : id = id ?? const Uuid().v4();

  FilterCondition copyWith({
    StudyProperty? property,
    FilterOperator? operator,
    dynamic value,
  }) {
    return FilterCondition(
      id: id,
      property: property ?? this.property,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [id, property, operator, value];
}

class FilterGroup extends FilterElement {
  @override
  final String id;
  final FilterLogic logic;
  final List<FilterElement> children; // Can be FilterCondition or FilterGroup

  FilterGroup({
    String? id,
    this.logic = FilterLogic.and,
    List<FilterElement>? children,
  }) : id = id ?? const Uuid().v4(),
       children = children ?? [];

  void add(FilterElement element) {
    children.add(element);
  }

  void remove(String id) {
    children.removeWhere((element) => element.id == id);
  }

  @override
  List<Object?> get props => [id, logic, children];
}

class SavedFilter {
  final String id;
  String name;
  FilterGroup root;
  String? sortColumn; // Matches StudiesTableColumn enum name
  bool sortAscending;
  bool isDefault;
  IconData? icon;
  DateTime createdAt;
  DateTime updatedAt;

  SavedFilter({
    required this.id,
    required this.name,
    required this.root,
    this.sortColumn,
    this.sortAscending = true,
    this.isDefault = false,
    this.icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}

class DefaultPresets {
  static SavedFilter get myActiveStudies => SavedFilter(
    id: 'preset_my_active_studies',
    name: 'My Active Studies',
    isDefault: true,
    icon: Icons.star_border_rounded,
    root: FilterGroup(
      children: [
        FilterCondition(
          property: StudyProperty.owner,
          operator: FilterOperator.equals,
          value: true,
        ),
        FilterCondition(
          property: StudyProperty.status,
          operator: FilterOperator.equals,
          value:
              'running', // Assuming 'running' matches StudyStatus.running.name
        ),
      ],
    ),
  );

  static SavedFilter get studiesNeedingAttention => SavedFilter(
    id: 'preset_needing_attention',
    name: 'Studies Needing Attention',
    isDefault: true,
    icon: Icons.error_outline_rounded,
    root: FilterGroup(
      children: [
        FilterCondition(
          property: StudyProperty.status,
          operator: FilterOperator.equals,
          value: 'running',
        ),
        // Simplistic logic: active subjects < 2 OR participant count < 5
        FilterGroup(
          logic: FilterLogic.or,
          children: [
            FilterCondition(
              property: StudyProperty.activeSubjectCount,
              operator: FilterOperator.lessThan,
              value: 2,
            ),
            FilterCondition(
              property: StudyProperty.participantCount,
              operator: FilterOperator.lessThan,
              value: 5,
            ),
          ],
        ),
      ],
    ),
  );

  static SavedFilter get recentlyCreated => SavedFilter(
    id: 'preset_recently_created',
    name: 'Recently Created',
    isDefault: true,
    icon: Icons.new_releases_outlined,
    root: FilterGroup(
      children: [
        FilterCondition(
          property: StudyProperty.createdAt,
          operator: FilterOperator.greaterThanOrEqual,
          value: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ],
    ),
  );

  static SavedFilter get publicStudies => SavedFilter(
    id: 'preset_public_studies',
    name: 'Public Studies',
    isDefault: true,
    icon: Icons.public_rounded,
    root: FilterGroup(
      logic: FilterLogic.or,
      children: [
        FilterCondition(
          property: StudyProperty.resultSharing,
          operator: FilterOperator.equals,
          value: 'public',
        ),
        FilterCondition(
          property: StudyProperty.registryPublished,
          operator: FilterOperator.equals,
          value: true,
        ),
      ],
    ),
  );

  static SavedFilter get draftStudies => SavedFilter(
    id: 'preset_draft_studies',
    name: 'Draft Studies',
    isDefault: true,
    icon: Icons.edit_note_rounded,
    root: FilterGroup(
      children: [
        FilterCondition(
          property: StudyProperty.status,
          operator: FilterOperator.equals,
          value: 'draft',
        ),
      ],
    ),
  );

  static List<SavedFilter> get all => [
    myActiveStudies,
    studiesNeedingAttention,
    recentlyCreated,
    publicStudies,
    draftStudies,
  ];
}
