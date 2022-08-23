import 'package:archive/archive.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/file_download.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension StudyExportZipX on StudyExportData {
  Archive get archive {
    final archive = Archive();
    final toCSVString = CSVStringEncoder();
    final toJsonString = JsonStringEncoder();

    final files = {
      'measurements.csv': toCSVString(measurementsData),
      'measurements.json': toJsonString(measurementsData),
      'interventions.csv': toCSVString(interventionsData),
      'interventions.json': toJsonString(interventionsData),
    };

    files.forEach((filename, content) {
      final archiveFile = ArchiveFile.string(filename, content);
      archive.addFile(archiveFile);
    });

    return archive;
  }

  List<int>? get encodedZip => ZipEncoder().encode(archive);

  String get defaultFilename =>
      '${study.title?.toKey() ?? ''}_${DateTime.now()}';

  downloadAsZip({String? filename}) {
    filename ??= defaultFilename;
    return downloadBytes(
      bytes: encodedZip!,
      filename: filename.ensureSuffix('.zip'),
    );
  }
}

extension StudyExportX on Study {
  bool canExport(User user) =>
      !exportData.isEmpty && (canEdit(user) || publishedToRegistryResults);

  String? exportDisabledReason(User user) {
    if (canExport(user)) return null;
    if (exportData.isEmpty) {
      return "There is not data available yet".hardcoded;
    }
    if (!canEdit(user) && !publishedToRegistryResults) {
      return "You do not have sufficient permission to access this study's data"
          .hardcoded;
    }
    return null;
  }
}
