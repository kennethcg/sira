import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String url = 'https://jujgnzbovzbdhbaamfiz.supabase.co';
  static const String anonKey =
      'sb_publishable_e_xpnJf0e7BCIgXg-bKXcw_OBo24YfR';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
