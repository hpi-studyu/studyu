import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:studyu_designer_v2/features/account/study_import_stub.dart'
    if (dart.library.html) 'package:studyu_designer_v2/features/account/study_import_web.dart'
    as platform;

class StudyImport() {
  static Future<bool> importStudy(WidgetRef ref) => platform.importStudy(ref);
}
