import 'package:flutter/foundation.dart';

/// ---------- Enums (v1 fields/operators) ----------

enum StudyField {
  title,              // String
  status,             // enum/string
  owner,              // userId/email/"me"
  createdAt,          // DateTime
  resultSharing,      // enum: private/public
  registryPublished,  // bool
  participation,      // num
  totalMissedDays,    // num
}

enum LogicalOp { and, or }

enum Predicate {
  equals,
  notEquals,
  contains,       // strings
  lessThan,       // numbers/dates
  greaterThan,    // numbers/dates
  between,        // numbers/dates (value..value2)
  inLastDays,     // rolling window (e.g., createdAt)
  isTrue,         // booleans
  isFalse,        // booleans
}

/// ---------- Node base type ----------

@immutable
abstract class FilterNode {
  final String id;

  /// Use a **named** parameter so subclasses can use `required super.id`.
  const FilterNode({required this.id});

  /// Discriminator for (de)serialization
  String get kind;
}

/// ---------- Leaf: ConditionNode ----------

@immutable
class ConditionNode extends FilterNode {
  @override
  String get kind => 'condition';

  final StudyField field;
  final Predicate predicate;
  final Object? value;   // string/num/bool/Date ISO; typed at compile step
  final Object? value2;  // for 'between'

  const ConditionNode({
    required super.id,
    required this.field,
    required this.predicate,
    this.value,
    this.value2,
  });

  ConditionNode copyWith({
    StudyField? field,
    Predicate? predicate,
    Object? value,
    Object? value2,
  }) {
    return ConditionNode(
      id: id,
      field: field ?? this.field,
      predicate: predicate ?? this.predicate,
      value: value ?? this.value,
      value2: value2 ?? this.value2,
    );
  }

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'id': id,
        'field': field.name,
        'predicate': predicate.name,
        'value': value,
        'value2': value2,
      };

  factory ConditionNode.fromJson(Map<String, dynamic> json) {
    return ConditionNode(
      id: json['id'] as String,
      field: StudyField.values.byName(json['field'] as String),
      predicate: Predicate.values.byName(json['predicate'] as String),
      value: json['value'],
      value2: json['value2'],
    );
  }
}

/// ---------- Composite: GroupNode (AND/OR) ----------

@immutable
class GroupNode extends FilterNode {
  @override
  String get kind => 'group';

  final LogicalOp op;
  final List<FilterNode> children;

  const GroupNode({
    required super.id,
    required this.op,
    required this.children,
  });

  GroupNode copyWith({
    LogicalOp? op,
    List<FilterNode>? children,
  }) {
    return GroupNode(
      id: id,
      op: op ?? this.op,
      children: children ?? this.children,
    );
  }

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'id': id,
    'op': op.name,
    'children': children.map(_nodeToJson).toList(),
  };

  factory GroupNode.fromJson(Map<String, dynamic> json) {
    final kids = (json['children'] as List<dynamic>? ?? [])
        .map((e) => _nodeFromJson(e as Map<String, dynamic>))
        .toList();

    return GroupNode(
      id: json['id'] as String,
      op: LogicalOp.values.byName(json['op'] as String),
      children: kids,
    );
  }
}

/// ---------- Root wrapper (filter draft) ----------

@immutable
class FilterDraft {
  final GroupNode root;
  const FilterDraft({required this.root});

  FilterDraft copyWith({GroupNode? root}) => FilterDraft(root: root ?? this.root);

  Map<String, dynamic> toJson() => {'root': root.toJson()};

  factory FilterDraft.fromJson(Map<String, dynamic> json) =>
      FilterDraft(root: GroupNode.fromJson(json['root'] as Map<String, dynamic>));
}

/// ---------- Helpers ----------

String newId() => DateTime.now().microsecondsSinceEpoch.toString();

Map<String, dynamic> _nodeToJson(FilterNode node) {
  if (node is GroupNode) return node.toJson();
  if (node is ConditionNode) return node.toJson();
  throw ArgumentError('Unknown node type: $node');
}

FilterNode _nodeFromJson(Map<String, dynamic> json) {
  switch (json['kind'] as String) {
    case 'group':
      return GroupNode.fromJson(json);
    case 'condition':
      return ConditionNode.fromJson(json);
    default:
      throw ArgumentError('Unknown node kind: ${json['kind']}');
  }
}
