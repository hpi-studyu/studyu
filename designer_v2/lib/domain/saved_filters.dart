import '../../domain/advanced_filters_model.dart'; // your GroupNode/ConditionNode

enum FilterScope { myStudies, publicStudies }
enum SortDirection { asc, desc }

class SortPreset {
  final String columnKey;
  final SortDirection direction;
  const SortPreset({required this.columnKey, this.direction = SortDirection.desc});

  Map<String, dynamic> toJson() => {
    'columnKey': columnKey,
    'direction': direction.name,
  };

  factory SortPreset.fromJson(Map<String, dynamic> j) => SortPreset(
    columnKey: j['columnKey'] as String,
    direction: (j['direction'] as String) == 'asc' ? SortDirection.asc : SortDirection.desc,
  );
}

class SavedFilter {
  final String id; // uuid
  final String name;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastUsedAt;
  final FilterScope scope;
  final GroupNode logicTree;
  final SortPreset? sortPreset;

  const SavedFilter({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    required this.scope,
    required this.logicTree,
    this.lastUsedAt,
    this.sortPreset,
  });

  SavedFilter copyWith({
    String? name,
    bool? isDefault,
    DateTime? updatedAt,
    DateTime? lastUsedAt,
    SortPreset? sortPreset,
  }) =>
      SavedFilter(
        id: id,
        name: name ?? this.name,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
        scope: scope,
        logicTree: logicTree,
        sortPreset: sortPreset ?? this.sortPreset,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'isDefault': isDefault,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastUsedAt': lastUsedAt?.toIso8601String(),
    'scope': scope.name,
    'logicTree': logicTree.toJson(),
    'sortPreset': sortPreset?.toJson(),
  };

  factory SavedFilter.fromJson(Map<String, dynamic> j) => SavedFilter(
    id: j['id'] as String,
    name: j['name'] as String,
    isDefault: (j['isDefault'] ?? false) as bool,
    createdAt: DateTime.parse(j['createdAt'] as String),
    updatedAt: DateTime.parse(j['updatedAt'] as String),
    lastUsedAt: j['lastUsedAt'] != null ? DateTime.parse(j['lastUsedAt'] as String) : null,
    scope: (j['scope'] as String) == 'publicStudies' ? FilterScope.publicStudies : FilterScope.myStudies,
    logicTree: GroupNode.fromJson(j['logicTree'] as Map<String, dynamic>),
    sortPreset: j['sortPreset'] == null ? null : SortPreset.fromJson(j['sortPreset'] as Map<String, dynamic>),
  );
}
