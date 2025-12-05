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

abstract class FilterElement {
  String get id;
}

class FilterCondition extends FilterElement {
  @override
  final String id;
  StudyProperty property;
  FilterOperator operator;
  dynamic value; // String, num, DateTime, bool, etc.

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
}

class FilterGroup extends FilterElement {
  @override
  final String id;
  FilterLogic logic;
  List<FilterElement> children; // Can be FilterCondition or FilterGroup

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
}

class SavedFilter {
  final String id;
  String name;
  FilterGroup root;
  String? sortColumn; // Matches StudiesTableColumn enum name
  bool sortAscending;
  bool isDefault;
  DateTime createdAt;
  DateTime updatedAt;

  SavedFilter({
    required this.id,
    required this.name,
    required this.root,
    this.sortColumn,
    this.sortAscending = true,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}
