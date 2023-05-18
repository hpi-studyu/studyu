import 'package:studyu_core/core.dart';

class DataReferenceIdentifier<T> extends DataReference<T> {
  DataReferenceIdentifier(super.task, super.property);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataReferenceIdentifier &&
          runtimeType == other.runtimeType &&
          task == other.task &&
          property == other.property;

  @override
  int get hashCode => task.hashCode ^ property.hashCode;
}
