import 'package:studyu_core/core.dart';

/*
typedef SupabaseQueryFilter = Map<String, String> Function(SupabaseObject record);
*/

extension SubjectProgressFK on SubjectProgress {
  /*
  /// Mapping from [SupabaseObject] type to the foreign key column referencing
  /// the type's corresponding table
  Map<Object, SupabaseQueryFilter> get foreignKeys => {
    [Study]: (SupabaseObject obj) {
      return {'study_id': (obj as Study).id};
    },
  };

   */

  Map<String, String> foreignKey(SupabaseObject record) {
    if (record is Study) {
      return {'study_id': record.id};
    }
    throw Exception("No foreign key configured");
  }
}
