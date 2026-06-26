import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState, User;
import 'package:supabase_flutter/supabase_flutter.dart' as supa show AuthState, User;

import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

part 'auth_provider.g.dart';

enum AuthStatus { loading, authenticated, unauthenticated, unconfirmed }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, user, error];
}

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    ref.listen(authStateChangesProvider, (prev, next) {
      next.whenData((supaState) {
        if (supaState.session != null && state.hasValue) {
          _fetchUserProfile();
        } else if (supaState.session == null) {
          state = const AsyncValue.data(
            AuthState(status: AuthStatus.unauthenticated),
          );
        }
      });
    });

    final session = SupabaseConfig.auth.currentSession;
    if (session == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }

    try {
      final user = await AuthService.getCurrentUser();
      return AuthState(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (e) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signUp(
        name: name, email: email, password: password, phone: phone,
      );
      await AuthService.signOut();
      state = const AsyncValue.data(
        AuthState(status: AuthStatus.unauthenticated),
      );
    } catch (e) {
      final errorMsg = (e is AppException) ? e.message : 'Terjadi kesalahan.';
      state = AsyncValue.error(AppException(message: errorMsg), StackTrace.current);
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncValue.loading();
    try {
      await AuthService.signIn(email: email, password: password);
      await _fetchUserProfile();
    } catch (e) {
      final errorMsg = (e is AppException) ? e.message : 'Terjadi kesalahan.';
      state = AsyncValue.error(AppException(message: errorMsg), StackTrace.current);
    }
  }

  Future<void> setRole(UserRole role) async {
    final session = SupabaseConfig.auth.currentSession;
    
    if (session == null) {
      state = AsyncValue.error(AppException(message: 'Sesi tidak ditemukan. Silakan login ulang.'), StackTrace.current);
      return;
    }
    
    try {
      final updatedUser = await AuthService.setRole(session.user.id, role);
      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: updatedUser),
      );
      
      // PERBAIKAN: Wajib memanggil ini agar GoRouter tahu perannya sudah ada
      // dan langsung menendang user dari layar Role Select ke Home!
      ref.invalidate(currentUserRoleProvider);
      
    } catch (e) {
      final errorMsg = (e is AppException) ? e.message : 'Terjadi kesalahan saat menyimpan peran.';
      state = AsyncValue.error(AppException(message: errorMsg), StackTrace.current);
    }
  }

  Future<void> signOut() async {
    try {
      await AuthService.signOut();
      state = const AsyncValue.data(AuthState(status: AuthStatus.unauthenticated));
    } catch (e) {
      final errorMsg = (e is AppException) ? e.message : 'Terjadi kesalahan.';
      state = AsyncValue.error(AppException(message: errorMsg), StackTrace.current);
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = await AuthService.getCurrentUser();
      state = AsyncValue.data(
        AuthState(status: AuthStatus.authenticated, user: user),
      );
    } catch (e) {
      final errorMsg = (e is AppException) ? e.message : 'Terjadi kesalahan.';
      state = AsyncValue.error(AppException(message: errorMsg), StackTrace.current);
    }
  }
}

@riverpod
Stream<supa.AuthState> authStateChanges(AuthStateChangesRef ref) {
  return SupabaseConfig.auth.onAuthStateChange;
}

@riverpod
Session? currentSession(CurrentSessionRef ref) {
  final authStateAsync = ref.watch(authStateChangesProvider);
  return authStateAsync.maybeWhen(
    data: (state) => state.session,
    orElse: () => SupabaseConfig.auth.currentSession,
  );
}

@riverpod
Future<String?> currentUserRole(CurrentUserRoleRef ref) async {
  final session = ref.watch(currentSessionProvider);
  if (session == null) return null;

  final row = await SupabaseConfig.client
      .from('profiles')
      .select('role')
      .eq('id', session.user.id)
      .maybeSingle();

  return row?['role'] as String?;
}