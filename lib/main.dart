import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    // Supabase sedang migrasi dari "anon key" (JWT, format lama) ke
    // "publishable key" (format sb_publishable_..., key lama akan
    // dihapus akhir 2026). `anonKey` masih diterima tapi deprecated.
    // Ambil publishable key dari Dashboard > Settings > API Keys.
    publishableKey: const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
  );

  runApp(const ProviderScope(child: PinjamAjaApp()));
}
