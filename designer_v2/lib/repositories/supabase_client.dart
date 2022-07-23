import 'package:studyu_core/core.dart';
import 'package:studyu_core/env.dart' as env;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

// TODO: Transfer networking code to core package (+ update app if needed)

/// Interface for implementation by any class that wants to use [SupabaseQueryMixin]
abstract class SupabaseClientDependant {
  SupabaseClient get supabaseClient;
}

/// An exception that is thrown when Supabase returns a [PostgrestResponse]
/// with an associated [PostgrestError]
class SupabaseQueryError implements Exception {
  SupabaseQueryError({
    required this.statusCode,
    required this.message,
    this.details
  });

  /// Status code of the erroneous [PostgrestResponse]
  final int? statusCode;

  /// The [PostgrestError] message associated with the [PostgrestResponse]
  final String message;

  /// The [PostgrestError] details associated with the [PostgrestResponse]
  final dynamic details;
}

typedef PostgrestDataCallback = Object Function(dynamic data);

extension PostgrestResponseX on PostgrestResponse {
  /// Processes the [data] with the given [callback] if there are no errors.
  /// Throws a [SupabaseQueryError] otherwise.
  guarded(PostgrestDataCallback callback) {
    if (hasError) {
      throw SupabaseQueryError(
          statusCode: status,
          message: error!.message,
          details: error!.details
      );
    }
    return callback(data); // TODO: resolve synchronous error in future
  }
}

/// Mixes in networking & deserialization logic into a [SupabaseClientDependant]
mixin SupabaseQueryMixin on SupabaseClientDependant {
  // - Networking

  Future<List<T>> getAll<T extends SupabaseObject>({
    List<String> selectedColumns = const ['*']
  }) async {
    final PostgrestResponse res = await supabaseClient.from(tableName(T))
        .select(selectedColumns.join(','))
        .execute();
    return res.guarded((data) => deserializeList<T>(data));
  }

  Future<T> getById<T extends SupabaseObject>(String id, {
    List<String> selectedColumns = const ['*']
  }) async {
    return getByColumn('id', id, selectedColumns: selectedColumns);
  }

  Future<T> getByColumn<T extends SupabaseObject>(String colName, String value, {
    List<String> selectedColumns = const ['*']
  }) async {
    final PostgrestResponse res = await supabaseClient.from(tableName(T))
        .select(selectedColumns.join(','))
        .eq(colName, value)
        .single()
        .execute();
    return res.guarded((data) => deserializeObject<T>(data));
  }

  // - Deserialization

  List<T> deserializeList<T extends SupabaseObject>(dynamic data) {
    return List<T>.from(
      List<Map<String, dynamic>>.from(data as List)
          .map((json) => SupabaseObjectFunctions.fromJson<T>(json))
    );
  }

  T deserializeObject<T extends SupabaseObject>(dynamic data) {
    return SupabaseObjectFunctions.fromJson<T>(data as Map<String, dynamic>);
  }
}

// Re-expose the global client object via Riverpod
final supabaseClientProvider = riverpod.Provider<SupabaseClient>(
        (ref) => env.client
);
