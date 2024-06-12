import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:studyu_designer_v2/localization/string_hardcoded.dart';
import 'package:studyu_designer_v2/utils/json_format.dart';
import 'package:studyu_designer_v2/utils/performance.dart';

dynamic downloadFile({required String fileContent, required String filename}) {
  final List<int> bytes = utf8.encode(fileContent);
  return downloadBytes(bytes: bytes, filename: filename);
}

void downloadBytes({required List<int> bytes, required String filename}) {
  if (!kIsWeb) {
    throw Exception(
      "The StudyU designer only support the web platform".hardcoded,
    );
  }
  final content = base64Encode(bytes);
  final anchor = AnchorElement(
    href: "data:application/octet-stream;charset=utf-16le;base64,$content",
  )
    ..style.display = 'none'
    ..download = filename;
  document.body?.append(anchor);
  anchor.click();
  anchor.remove();
}

abstract class FileFormatEncoder {
  Future<String> encodeAsync(List<Map<String, dynamic>> records) {
    return runInBackground<String>(() => encode(records));
  }

  String encode(List<Map<String, dynamic>> records);

  String call(List<Map<String, dynamic>> records) {
    return encode(records);
  }
}

class CSVStringEncoder extends FileFormatEncoder {
  @override
  String encode(List<Map<String, dynamic>> records) {
    final Set<String> columnNames = {};
    for (final record in records) {
      columnNames.addAll(record.keys);
    }

    final headerRow = columnNames.toList();
    final dataRows = records.map((record) {
      final row = [];
      for (final columnName in headerRow) {
        final cellValue =
            record[columnName] ?? ''; // fill missing columns with empty string
        row.add(cellValue);
      }
      return row;
    }).toList();

    final table = [headerRow, ...dataRows];
    return const ListToCsvConverter().convert(table);
  }
}

class JsonStringEncoder extends FileFormatEncoder {
  @override
  String encode(List<Map<String, dynamic>> records) {
    return prettyJson(records);
  }
}
