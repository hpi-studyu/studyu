import 'package:studyu_designer_v2/utils/typings.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

abstract class JsonFileLoader {
  /// Path to the directory containing the JSON files to be loaded
  final String jsonAssetsPath;

  JsonFileLoader(this.jsonAssetsPath);

  Future<String> loadJson(String filename) async {
    return await rootBundle.loadString(jsonAssetsPath + filename);
  }

  // TODO: figure out Union types here for JsonMap | JsonList
  Future<JsonMap> parseJsonMapFromAssets(String filename) async {
    final jsonString = await rootBundle.loadString(jsonAssetsPath + filename);
    final result = await jsonDecode(jsonString);
    return result;
  }

  Future<JsonList> parseJsonListFromAssets(String filename) async {
    final jsonString = await rootBundle.loadString(jsonAssetsPath + filename);
    final result = await jsonDecode(jsonString);
    return result;
  }
}
