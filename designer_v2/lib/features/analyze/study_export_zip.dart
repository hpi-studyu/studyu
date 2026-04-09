import 'dart:developer' as developer;

import 'package:archive/archive.dart';
import 'package:studyu_core/core.dart';
import 'package:studyu_designer_v2/domain/study.dart';
import 'package:studyu_designer_v2/domain/study_export.dart';
import 'package:studyu_designer_v2/localization/app_translation.dart';
import 'package:studyu_designer_v2/utils/extensions.dart';
import 'package:studyu_designer_v2/utils/file_download.dart';
import 'package:studyu_designer_v2/utils/json_format.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

extension StudyExportZipX on StudyExportData {
  Future<Archive> get archive async {
    final archive = Archive();
    final toCSVString = CSVStringEncoder();
    final toJsonString = JsonStringEncoder();

    developer.log(
      'Building export archive for study ${study.id} (${study.title})',
      name: 'StudyExportZip',
    );

    final files = {
      'study_definition.json': prettyJson(study.toJson()),
      'measurements.csv': toCSVString(measurementsData),
      'measurements.json': toJsonString(measurementsData),
      'interventions.csv': toCSVString(interventionsData),
      'interventions.json': toJsonString(interventionsData),
    };

    files.forEach((filename, content) {
      final archiveFile = ArchiveFile.string(filename, content);
      archive.addFile(archiveFile);
    });

    for (final mediaFile in mediaData) {
      developer.log(
        'Downloading media asset for export: $mediaFile',
        name: 'StudyExportZip',
      );
      final content = await BlobStorageHandler().downloadObservation(mediaFile);
      final archiveFile = ArchiveFile(mediaFile, content.length, content);
      archive.addFile(archiveFile);
    }

    developer.log(
      'Archive build complete for study ${study.id}; files=${archive.length}',
      name: 'StudyExportZip',
    );
    return archive;
  }

  Future<List<int>?> get encodedZip async => ZipEncoder().encode(await archive);

  String get defaultFilename =>
      '${study.title?.toKey() ?? ''}_${DateTime.now()}';

  Future downloadAsZip({String? filename}) async {
    filename ??= defaultFilename;
    try {
      final zipBytes = (await encodedZip)!;
      developer.log(
        'Downloading zip for study ${study.id} as ${filename.ensureSuffix('.zip')} (${zipBytes.length} bytes)',
        name: 'StudyExportZip',
      );
      return downloadBytes(
        bytes: zipBytes,
        filename: filename.ensureSuffix('.zip'),
      );
    } catch (error, stackTrace) {
      developer.log(
        'Zip export failed for study ${study.id} (${study.title}): $error',
        name: 'StudyExportZip',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

extension StudyExportX on Study {
  bool canExport(User user) =>
      (canEdit(user) || publishedToRegistryResults) &&
      (participants?.isNotEmpty ?? false);

  String? exportDisabledReason(User user) {
    if (canExport(user)) return null;
    if (!canEdit(user) && !publishedToRegistryResults) {
      return tr.study_export_unavailable_no_permission_tooltip;
    }
    if (participants?.isEmpty ?? true) {
      return tr.study_export_unavailable_empty_tooltip;
    }
    return null;
  }
}

extension StudyDefinitionExportX on Study {
  void downloadDefinition() {
    final json = prettyJson((this as dynamic).toJson());
    final filename = '${title?.toKey() ?? ''}_study_definition.json';
    downloadFile(fileContent: json, filename: filename);
  }
}
