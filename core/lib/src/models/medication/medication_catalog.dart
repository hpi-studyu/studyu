import 'package:studyu_core/src/env/env.dart';

import 'medication_product_snapshot.dart';

class MedicationCatalog {
  const MedicationCatalog._();

  static Future<MedicationProductSnapshot?> lookupByPzn(String pzn) async {
    final response = await client.rpc<dynamic>(
      'lookup_bfarm_medication',
      params: {'p_pzn': pzn},
    );
    if (response == null) return null;
    return MedicationProductSnapshot.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  static Future<List<MedicationProductSnapshot>> searchByName(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await client.rpc<dynamic>(
      'search_bfarm_medications',
      params: {'p_query': query, 'p_limit': limit, 'p_offset': offset},
    );
    return (response as List)
        .map(
          (item) => MedicationProductSnapshot.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
