import 'env.dart';

class SupabaseConfig {
  static bool get isConfigured =>
      Env.supabaseUrl.isNotEmpty &&
      !Env.supabaseUrl.contains('placeholder') &&
      Env.supabaseAnonKey.isNotEmpty &&
      !Env.supabaseAnonKey.contains('placeholder');
}
