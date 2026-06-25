import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../models/user.dart';

/// Service layer untuk Authentication. Semua logic auth (sign up, sign in, dll)
/// harus lewat sini BUKAN langsung ke Supabase di provider/screen.
///
/// Error handling:
/// - Tangkap AuthException dari Supabase
/// - Convert ke AppException dengan pesan Bahasa Indonesia yang user-friendly
class AuthService {
  const AuthService._();

  static final _client = SupabaseConfig.client;
  static final _auth = SupabaseConfig.auth;

  /// Sign up user baru dengan email, password, nama, dan nomor HP.
  ///
  /// Steps:
  /// 1. Panggil supabase.auth.signUp()
  /// 2. Insert ke tabel 'profiles' dengan data user
  /// 3. Return AuthResponse jika sukses, throw AppException jika gagal
  static Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      // Validasi input
      if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
        throw AppException(
          message: 'Email, password, nama, dan nomor HP tidak boleh kosong.',
        );
      }

      // Sign up ke Supabase Auth
      final response = await _auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AppException(message: 'Gagal membuat akun. Coba lagi.');
      }

      // Insert profile ke tabel 'profiles' (role default di database)
      await _client.from('profiles').insert({
        'id': response.user!.id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': 'renter', // Default role (bisa diubah di role-select)
        'created_at': DateTime.now().toIso8601String(),
      });

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppException(
        message: 'Terjadi kesalahan saat mendaftar. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Sign in user dengan email dan password.
  ///
  /// Steps:
  /// 1. Panggil supabase.auth.signInWithPassword()
  /// 2. Return AuthResponse jika sukses, throw AppException jika gagal
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw AppException(message: 'Email dan password tidak boleh kosong.');
      }

      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      return response;
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppException(
        message: 'Terjadi kesalahan saat login. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Sign out user saat ini.
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AppException(
        message: 'Gagal logout. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Ambil current user dari session, atau null jika tidak ada session.
  static Future<User?> getCurrentUser() async {
    try {
      final session = _auth.currentSession;
      if (session == null) return null;

      // Fetch profile dari database
      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (profile == null) return null;

      // Tambahkan email dari session ke profile map
      profile['email'] = session.user.email ?? '';

      return User.fromJson(profile);
    } catch (e) {
      throw AppException(
        message: 'Gagal mengambil data user. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Update role user di tabel 'profiles' dan return updated User object.
  static Future<User> setRole(String userId, UserRole role) async {
    try {
      final updated = await _client
          .from('profiles')
          .update({'role': role.toDb()})
          .eq('id', userId)
          .select()
          .single();

      // Tambahkan email dari session
      final session = _auth.currentSession;
      if (session != null) {
        updated['email'] = session.user.email ?? '';
      }

      return User.fromJson(updated);
    } catch (e) {
      throw AppException(
        message: 'Gagal menyimpan peran. Coba lagi.',
        originalError: e,
      );
    }
  }

  /// Listen ke perubahan auth state dari Supabase (sign in, sign out, token refresh, dll).
  static Stream<AuthState> authStateChanges() {
    return _auth.onAuthStateChange;
  }

  /// Helper: Convert Supabase AuthException ke AppException dengan pesan Bahasa Indonesia.
  static AppException _handleAuthException(AuthException e) {
    final message = switch (e.statusCode) {
      'invalid_grant' =>
        'Email atau password salah. Coba lagi.',
      'user_already_exists' =>
        'Email sudah terdaftar. Gunakan email lain atau login.',
      'weak_password' =>
        'Password terlalu lemah. Minimal 8 karakter dengan huruf dan angka.',
      'invalid_email' =>
        'Format email tidak valid.',
      'email_not_confirmed' =>
        'Email belum diverifikasi. Cek inbox atau spam folder Anda.',
      'user_not_found' =>
        'Akun tidak ditemukan.',
      'invalid_api_key' =>
        'Konfigurasi API tidak valid. Hubungi admin.',
      'over_email_send_rate_limit' =>
        'Terlalu banyak percobaan. Tunggu beberapa menit.',
      'validation_failed' =>
        'Data tidak valid. Periksa kembali input Anda.',
      _ => e.message,
    };

    return AppException(
      message: message,
      code: e.statusCode,
      originalError: e,
    );
  }
}
