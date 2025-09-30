// domain/property_meta.dart
import 'package:flutter/foundation.dart';

/// Supported property types for the filter system.
enum PropertyType {
  string,
  number,
  boolean,
  date,
  datetime,
  enumeration,   // requires enumOptions
}

/// Basic metadata for a property that can be filtered on.
@immutable
class PropertyMeta {
  final String id;               // e.g. "status", "createdAt"
  final String label;            // UI label
  final PropertyType type;
  final bool multi;              // allow multiple values? (for enums)
  final List<EnumOption> enumOptions; // when type == enumeration
  final num? min;                // numeric lower bound (optional)
  final num? max;                // numeric upper bound (optional)

  const PropertyMeta({
    required this.id,
    required this.label,
    required this.type,
    this.multi = false,
    this.enumOptions = const [],
    this.min,
    this.max,
  });

  bool get isEnum => type == PropertyType.enumeration;
}

@immutable
class EnumOption {
  final String key;   // canonical key to store, e.g. "active"
  final String label; // user-friendly label, e.g. "Active"
  const EnumOption(this.key, this.label);
}
