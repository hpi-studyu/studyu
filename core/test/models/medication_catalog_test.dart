import 'dart:convert';
import 'dart:io';

import 'package:studyu_core/core.dart';
import 'package:supabase/supabase.dart';
import 'package:test/test.dart';

void main() {
  late HttpServer server;
  late SupabaseClient supabaseClient;

  setUpAll(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    supabaseClient = SupabaseClient(
      'http://${server.address.address}:${server.port}',
      'test-anon-key',
    );
    setEnv(
      'http://${server.address.address}:${server.port}',
      'test-anon-key',
      supabaseClient: supabaseClient,
    );

    server.listen((request) async {
      final body = jsonDecode(await utf8.decoder.bind(request).join());
      request.response.headers.contentType = ContentType.json;

      if (request.uri.path == '/rest/v1/rpc/lookup_bfarm_medication') {
        if ((body as Map<String, dynamic>)['p_pzn'] == 'missing') {
          request.response.write('null');
        } else {
          request.response.write(jsonEncode(_snapshotJson));
        }
      } else if (request.uri.path == '/rest/v1/rpc/search_bfarm_medications') {
        request.response.write(jsonEncode([_snapshotJson]));
      } else {
        request.response.statusCode = HttpStatus.notFound;
      }

      await request.response.close();
    });
  });

  tearDownAll(() async {
    await supabaseClient.dispose();
    await server.close(force: true);
  });

  test('lookupByPzn decodes a product and preserves missing results', () async {
    final product = await MedicationCatalog.lookupByPzn('03752864');
    final missing = await MedicationCatalog.lookupByPzn('missing');

    expect(product?.pzn, '03752864');
    expect(product?.officialName, 'Ibuprofen Test 400 mg Filmtabletten');
    expect(
      product?.components.single.activeIngredients.single.name,
      'Ibuprofen',
    );
    expect(missing, isNull);
  });

  test('searchByName decodes every returned product', () async {
    final products = await MedicationCatalog.searchByName(
      'ibuprofen',
      limit: 10,
      offset: 20,
    );

    expect(products, hasLength(1));
    expect(products.single.pzn, '03752864');
    expect(products.single.source.releaseDate, '2026-09-15');
  });
}

const _snapshotJson = <String, dynamic>{
  'pzn': '03752864',
  'officialName': 'Ibuprofen Test 400 mg Filmtabletten',
  'activeIngredientCount': 1,
  'dosageForm': {
    'patientFriendlyShort': 'Tablet',
    'patientFriendlyLong': null,
    'bfarmName': 'Tablette',
    'bfarmTermId': 'T1',
  },
  'components': [
    {
      'key': 'rpp-1',
      'number': 1,
      'dosageForm': {
        'patientFriendlyShort': 'Tablet',
        'patientFriendlyLong': null,
        'bfarmName': 'Tablette',
        'bfarmTermId': 'T1',
      },
      'description': null,
      'activeIngredients': [
        {
          'key': 'rse-1',
          'name': 'Ibuprofen',
          'strength': '400 mg',
          'bfarmSubstanceId': null,
          'rank': 1,
        },
      ],
    },
  ],
  'source': {
    'name': 'BfArM Referenzdatenbank gemäß § 31b SGB V',
    'releaseDate': '2026-09-15',
  },
};
