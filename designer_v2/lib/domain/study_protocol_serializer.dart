import 'dart:convert';

import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/serialization/export/study_export_service.dart';
import 'package:studyu_designer_v2/domain/serialization/import/study_import_service.dart';
import 'package:studyu_designer_v2/utils/json_format.dart';

class StudyProtocolSerializer {
  StudyProtocolSerializer._();

  static Map<String, dynamic> exportStudy(Study study) {
    return StudyExportService.exportStudy(study);
  }

  static void applyToStudy(Study target, Map<String, dynamic> json) {
    StudyImportService.applyToStudy(target, json);
  }

  static String encodePretty(Map<String, dynamic> payload) {
    return prettyJson(payload);
  }

  static Map<String, dynamic> decode(String content) {
    final decoded = jsonDecode(content);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Study protocol must be a JSON object');
    }
    return decoded;
  }
}
