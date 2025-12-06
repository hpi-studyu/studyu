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
  const FilterElement();
  String get id;

  Map<String, dynamic> toJson();

  factory FilterElement.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == 'group') {
      return FilterGroup.fromJson(json);
    } else if (type == 'condition') {
      return FilterCondition.fromJson(json);
    }
    throw ArgumentError('Unknown FilterElement type: $type');
  }
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

  factory FilterCondition.fromJson(Map<String, dynamic> json) {
    final property = StudyProperty.values.byName(json['property'] as String);
    final operator = FilterOperator.values.byName(json['operator'] as String);
    dynamic value = json['value'];

    // Handle DateTime deserialization
    if (property == StudyProperty.createdAt && value is String) {
      value = DateTime.parse(value);
    }

    return FilterCondition(
      id: json['id'] as String?,
      property: property,
      operator: operator,
      value: value,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    dynamic serializedValue = value;
    if (value is DateTime) {
      serializedValue = (value as DateTime).toIso8601String();
    }

    return {
      'type': 'condition',
      'id': id,
      'property': property.name,
      'operator': operator.name,
      'value': serializedValue,
    };
  }

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

  factory FilterGroup.fromJson(Map<String, dynamic> json) {
    return FilterGroup(
      id: json['id'] as String?,
      logic: FilterLogic.values.byName(json['logic'] as String),
      children: (json['children'] as List<dynamic>)
          .map((e) => FilterElement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'group',
      'id': id,
      'logic': logic.name,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }

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

  factory SavedFilter.fromJson(Map<String, dynamic> json) {
    return SavedFilter(
      id: json['id'] as String,
      name: json['name'] as String,
      root: FilterGroup.fromJson(json['root'] as Map<String, dynamic>),
      sortColumn: json['sort_column'] as String?,
      sortAscending: json['sort_ascending'] as bool? ?? true,
      isDefault: json['is_default'] as bool? ?? false,
      // Icon is NOT serialized
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'root': root.toJson(),
      'sort_column': sortColumn,
      'sort_ascending': sortAscending,
      'is_default': isDefault,
      // Icon is NOT serialized
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
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
