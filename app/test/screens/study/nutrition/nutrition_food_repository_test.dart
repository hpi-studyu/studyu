import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:studyu_app/screens/study/nutrition/nutrition_food_repository.dart';
import 'package:studyu_core/core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('loads only active library-visible subject definitions', () async {
    late Uri requestedUri;
    final repository = NutritionFoodRepository(
      client: _client((request) async {
        requestedUri = request.url;
        return _jsonResponse([_definitionRow()], request);
      }),
    );

    final templates = await repository.loadTemplates('subject');

    expect(templates.single.id, 'food-definition');
    expect(templates.single.prototype.foodVersionId, 'version-1');
    expect(templates.single.tags, ['fruit']);
    expect(requestedUri.query, contains('subject_id=eq.subject'));
    expect(requestedUri.query, contains('library_visible=eq.true'));
    expect(requestedUri.query, contains('deleted_at=is.null'));
  });

  test('historical mutation returns explicit update counts', () async {
    late Map<String, dynamic> params;
    final repository = NutritionFoodRepository(
      client: _client((request) async {
        params = jsonDecode(request.body) as Map<String, dynamic>;
        return _jsonResponse(_mutationResponse(), request);
      }),
    );

    final result = await repository.mutateHistoricalDefinition(
      subjectId: 'subject',
      snapshot: _food(),
      expectedVersionId: 'version-1',
      entryId: 'selected-entry',
      target: const {'taskId': 'task'},
      currentStudyDay: 5,
      mutationId: 'mutation',
    );

    expect(params['p_historical_entry_id'], 'selected-entry');
    expect(params['p_food_id'], 'food-definition');
    expect(result.progress, hasLength(3));
    expect(result.selectedHistoricalUpdateCount, 1);
    expect(result.todayUpdateCount, 2);
  });

  test('creates missing entry definitions through the mutation RPC', () async {
    final requests = <http.BaseRequest>[];
    final repository = NutritionFoodRepository(
      client: _client((request) async {
        requests.add(request);
        if (request.method == 'GET') return _jsonResponse([], request);
        final params = jsonDecode(request.body) as Map<String, dynamic>;
        expect(params['p_food_id'], 'food-definition');
        expect(params['p_expected_version_id'], isNull);
        expect(params['p_library_visible'], isFalse);
        expect(params['p_mutation_id'], isA<String>());
        return _jsonResponse(_mutationResponse(), request);
      }),
    );
    final food = _food(versionId: 'provisional-version');

    await repository.ensureDefinitions(subjectId: 'subject', foods: [food]);

    expect(requests, hasLength(2));
    expect(food.foodVersionId, 'version-1');
  });
}

http.Response _jsonResponse(Object? body, http.BaseRequest request) =>
    http.Response(
      jsonEncode(body),
      200,
      headers: const {'content-type': 'application/json'},
      request: request,
    );

SupabaseClient _client(MockClientHandler handler) => SupabaseClient(
  'https://example.supabase.co',
  'test-key',
  httpClient: MockClient(handler),
);

Map<String, dynamic> _definitionRow() => {
  'id': 'food-definition',
  'subject_id': 'subject',
  'deleted_at': null,
  'created_at': '2026-07-15T08:00:00.000Z',
  'updated_at': '2026-07-15T08:00:00.000Z',
  'nutrition_food_version': {'snapshot': _food().toJson()},
};

Map<String, dynamic> _mutationResponse() => {
  'definition': {
    'id': 'food-definition',
    'subjectId': 'subject',
    'kind': 'food',
    'currentVersionId': 'version-1',
    'deletedAt': null,
    'snapshot': _food().toJson(),
    'createdAt': '2026-07-15T08:00:00.000Z',
    'updatedAt': '2026-07-15T08:00:00.000Z',
  },
  'progress': const [
    {'task_id': 'historical-task'},
    {'task_id': 'today-task-a'},
    {'task_id': 'today-task-b'},
  ],
  'selectedHistoricalUpdateCount': 1,
  'todayUpdateCount': 2,
};

FoodEntry _food({String versionId = 'version-1'}) => FoodEntry(
  id: 'snapshot',
  foodId: 'food-definition',
  foodVersionId: versionId,
  entryType: FoodEntryType.singleIngredient,
  name: 'Apple',
  amount: 1,
  unit: 'serving',
  servingSizeGrams: 100,
  portionEstimationMethod: PortionEstimationMethod.standardUnit,
  portionState: PortionState.asServed,
  nutrition: NutritionProfile(
    energyKcal: 100,
    protein: 1,
    carbs: 1,
    fat: 1,
    sugars: 0,
    fiber: 0,
    saturatedFat: 0,
    transFat: 0,
    cholesterol: 0,
    sodium: 0,
    waterContent: 0,
    micros: const {},
  ),
  source: FoodSource.manual,
  confidenceScore: 1,
  createdAt: DateTime.utc(2026, 7, 15, 8),
  originalValues: const {
    '_libraryTags': ['fruit'],
  },
);
