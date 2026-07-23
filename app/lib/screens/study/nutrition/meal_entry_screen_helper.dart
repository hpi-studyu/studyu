import 'dart:convert';

import 'package:studyu_core/core.dart';

MealLog cloneMealLog(MealLog meal) => MealLog.fromJson(
  jsonDecode(jsonEncode(meal.toJson())) as Map<String, dynamic>,
);
