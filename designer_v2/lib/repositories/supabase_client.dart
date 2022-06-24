import 'package:studyu_core/env.dart' as env;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

// Re-expose the global client object via Riverpod
final supabaseClientProvider = riverpod.Provider<SupabaseClient>(
        (ref) => env.client
);
