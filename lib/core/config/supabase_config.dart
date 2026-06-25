import 'package:supabase_flutter/supabase_flutter.dart';

/// Wrapper akses ke Supabase client.
///
/// Inisialisasi WAJIB dipanggil sekali di `main()` sebelum `runApp()`:
///
/// ```dart
/// await Supabase.initialize(
///   url: const String.fromEnvironment('SUPABASE_URL'),
///   publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
/// );
/// ```
///
/// Karena pakai `String.fromEnvironment` (compile-time constant), jalankan
/// app dengan `--dart-define`, contoh:
///
/// ```
/// flutter run \
///   --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///   --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_xxxx
/// ```
class SupabaseConfig {
  SupabaseConfig._();

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static RealtimeClient get realtime => client.realtime;
}
