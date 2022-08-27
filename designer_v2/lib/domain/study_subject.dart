import 'package:studyu_core/core.dart';

extension StudySubjectFK on StudySubject {
  Map<String, String> foreignKey(SupabaseObject record) {
    if (record is Study) {
      return {'study_id': record.id};
    }
    throw Exception("No foreign key configured");
  }
}
