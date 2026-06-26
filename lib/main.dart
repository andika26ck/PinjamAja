import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

// TODO: GANTI VALUE DI BAWAH DENGAN PROJECT URL & ANON KEY DARI DASHBOARD SUPABASE LU
const String supabaseUrl = 'https://GANTI_DENGAN_PROJECT_URL_LU.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI...GANTI_DENGAN_ANON_KEY_LU';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase sekarang langsung nembak variabel string di atas, 
  // bukan pakai String.fromEnvironment lagi biar nggak error "No host specified".
  await Supabase.initialize(
    url: 'https://wbnqkwljddvrynpvqrop.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndibnFrd2xqZGR2cnlucHZxcm9wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIzMjY3ODgsImV4cCI6MjA5NzkwMjc4OH0.Vn1y5GwPa8DKREIxIGuU4qVMWe6M54jOdWf3pEQQ0sg', 
  );

  runApp(const ProviderScope(child: PinjamAjaApp()));
}