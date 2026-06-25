import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final GlobalKey<FormState> _formKey;
  bool _passwordObscured = true;
  bool _confirmPasswordObscured = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController(text: '+62');
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // PERBAIKAN: _handleRegister sekarang pakai async dan try-catch
  Future<void> _handleRegister() async {
    // Tutup keyboard saat tombol ditekan
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      try {
        // Await proses signUp dari provider
        await ref.read(authProvider.notifier).signUp(
              name: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              phone: _phoneController.text.trim(),
            );

        // Jika berhasil dan context masih aktif
        if (mounted) {
          // Tampilan Notif Sukses Keren
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Akun berhasil dibuat! Silakan login.',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
            ),
          );

          // Langsung tendang ke halaman login tanpa nunggu delay
          context.go('/login');
        }
      } catch (e) {
        // Jika gagal dan context masih aktif
        if (mounted) {
          // Tampilan Notif Error Keren
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      e.toString().replaceAll('Exception: ', ''),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.redAccent.shade700,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kita tetap memantau authProvider untuk mendapatkan status isLoading
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    // PERBAIKAN: ref.listen dihapus karena logic snackbar 
    // sudah dipindah ke dalam try-catch di fungsi _handleRegister.

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Akun',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buat akun baru untuk memulai.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              // Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    Text('Nama Lengkap',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama lengkap',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        if (value.length < 3) {
                          return 'Nama minimal 3 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Nomor HP
                    Text('Nomor HP',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: '+62812345678',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor HP tidak boleh kosong';
                        }
                        // Remove +62 prefix untuk validasi panjang
                        final digits =
                            value.replaceAll(RegExp(r'[^0-9]'), '');
                        if (digits.length < 10 || digits.length > 13) {
                          return 'Nomor HP harus 10-13 digit';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Email
                    Text('Email',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'nama@email.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password
                    Text('Password',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _passwordObscured,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Minimal 8 karakter',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordObscured = !_passwordObscured;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 8) {
                          return 'Password minimal 8 karakter';
                        }
                        if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                          return 'Password harus mengandung huruf';
                        }
                        if (!RegExp(r'[0-9]').hasMatch(value)) {
                          return 'Password harus mengandung angka';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Konfirmasi Password
                    Text('Konfirmasi Password',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _confirmPasswordObscured,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'Ketik ulang password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordObscured =
                                  !_confirmPasswordObscured;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password tidak boleh kosong';
                        }
                        if (value != _passwordController.text) {
                          return 'Password tidak cocok';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Tombol Daftar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleRegister,
                  child: isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      : const Text('Daftar'),
                ),
              ),
              const SizedBox(height: 16),
              // TextButton Login
              Center(
                child: TextButton(
                  onPressed: isLoading ? null : () => context.go('/login'),
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}