import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:studyu_core/core.dart';

class TemplateStorageManager {
  static const String _foodTemplatesKey = 'studyu_food_templates';

  static SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<List<SavedFoodTemplate>> loadFoodTemplates(String userId) async {
    final prefs = await _getPrefs();
    final key = '${_foodTemplatesKey}_$userId';
    final jsonString = prefs.getString(key);
    final templates = <SavedFoodTemplate>[];

    if (jsonString != null) {
      try {
        final jsonList = jsonDecode(jsonString) as List;
        templates.addAll(
          jsonList.map(
            (json) => SavedFoodTemplate.fromJson(json as Map<String, dynamic>),
          ),
        );
      } catch (e) {
        StudyULogger.error('Failed to load food templates: $e');
      }
    }

    return templates;
  }

  Future<void> saveFoodTemplate(SavedFoodTemplate template) async {
    final prefs = await _getPrefs();
    final key = '${_foodTemplatesKey}_${template.userId}';
    final templates = await loadFoodTemplates(template.userId);
    final existingIndex = templates.indexWhere((t) => t.id == template.id);
    if (existingIndex >= 0) {
      templates[existingIndex] = template;
    } else {
      templates.add(template);
    }
    await prefs.setString(
      key,
      jsonEncode(templates.map((template) => template.toJson()).toList()),
    );
  }

  Future<void> deleteFoodTemplate(String userId, String templateId) async {
    final prefs = await _getPrefs();
    final key = '${_foodTemplatesKey}_$userId';
    final templates = await loadFoodTemplates(userId);
    templates.removeWhere((t) => t.id == templateId);
    await prefs.setString(
      key,
      jsonEncode(templates.map((template) => template.toJson()).toList()),
    );
  }

  Future<List<SavedFoodTemplate>> searchFoodTemplates(
    String userId,
    String query,
  ) async {
    final templates = await loadFoodTemplates(userId);
    final lowerQuery = query.toLowerCase();
    return templates
        .where((t) => t.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
