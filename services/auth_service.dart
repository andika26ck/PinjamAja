import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../models/user.dart';

class AuthService {
  const AuthService._();

  static final _client = SupabaseConfig.client;
  static final _auth = SupabaseConfig.auth;

  /// Sign up user baru.
  /// 
  /// PERUBAHAN BARU:
  /// Kita sekarang mengirimkan `name` dan `phone` lewat parameter `data`.
  /// Ini akan masuk ke `raw_user_meta_data` di Supabase, yang nantinya
  /// akan ditangkap oleh Trigger Database (handle_new_user) untuk otomatis
  /// membuatkan baris di tabel `profiles`.
  static Future<AuthResponse> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
        throw AppException(
          message: 'Email, password, nama, dan nomor HP tidak boleh kosong.',
        );
      }

      // Sign up ke Supabase Auth dengan metadata
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
        },
      );

      if (response.user == null) {
        throw AppException(message: 'Gagal membuat akun. Coba lagi.');
      }

      // HAPUS KODE INSERT MANUAL KE 'profiles'
      // Karena database sekarang pakai Trigger untuk otomatis insert.

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

  static Future<User?> getCurrentUser() async {
    try {
      final session = _auth.currentSession;
      if (session == null) return null;

      final profile = await _client
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (profile == null) return null;

      profile['email'] = session.user.email ?? '';

      return User.fromJson(profile);
    } catch (e) {
      throw AppException(
        message: 'Gagal mengambil data user. Coba lagi.',
        originalError: e,
      );
    }
  }

  static Future<User> setRole(String userId, UserRole role) async {
    try {
      final updated = await _client
          .from('profiles')
          .update({'role': role.toDb()})
          .eq('id', userId)
          .select()
          .single();

      final session = _auth.currentSession;
      if (session != null) {
        updated['email'] = session.user.email ?? '';
      }

      return User.fromJson(updated);
    } catch (e, stacktrace) {
      print('=== ERROR SET ROLE BONGKAR ===');
      print(e.toString());
      print(stacktrace);
      
      throw AppException(
        message: 'Gagal menyimpan peran. Coba lagi.',
        originalError: e,
      );
    }
  }

  static Stream<AuthState> authStateChanges() {
    return _auth.onAuthStateChange;
  }

  static AppException _handleAuthException(AuthException e) {
    final message = switch (e.statusCode) {
      'invalid_grant' =>
        'Email atau password salah. Coba lagi.',
      'user_already_exists' =>
        'Email sudah terdaftar. Gunakan email lain atau login.',
      'weak_password' =>
        'Password terlalu lemah. Minimal 8 karakter.',
      _ => e.message,
    };

    return AppException(
      message: message,
      code: e.statusCode,
      originalError: e,
    );
  }
}