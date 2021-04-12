import 'package:supabase/supabase.dart';

const supabaseUrl = 'https://urrbcqpjcgokldetihiw.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYW5vbiIsImlhdCI6MTYxNzUzMDYwMSwiZXhwIjoxOTMzMTA2NjAxfQ.T-QhpPisubwjOn3P1Gj3DV-2Mb_ztzvLwiVYWrGFvVA';

final client = SupabaseClient(supabaseUrl, supabaseAnonKey);
