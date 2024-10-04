import 'package:archive/archive.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/file_download.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension StudyExportZipX on StudyExportData {
  Future<Archive> get archive async {
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
      final archiveFile = ArchiveFile.string(
        filename,
        // todo sanitize contents manually until archive v4 is released
        content.replaceAll('’', "'").replaceAll('…', '...'),
      );
      archive.addFile(archiveFile);
    });

    for (final mediaFile in mediaData) {
      final content = await BlobStorageHandler().downloadObservation(mediaFile);
      final archiveFile = ArchiveFile(mediaFile, content.length, content);
      archive.addFile(archiveFile);
    }

    return archive;
  }

  Future<List<int>?> get encodedZip async => ZipEncoder().encode(await archive);

  String get defaultFilename =>
      '${study.title?.toKey() ?? ''}_${DateTime.now()}';

  Future downloadAsZip({String? filename}) async {
    filename ??= defaultFilename;
    return downloadBytes(
      bytes: (await encodedZip)!,
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
      return tr.study_export_unavailable_empty_tooltip;
    }
    if (!canEdit(user) && !publishedToRegistryResults) {
      return tr.study_export_unavailable_no_permission_tooltip;
    }
    return null;
  }
}
