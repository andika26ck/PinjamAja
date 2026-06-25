import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  UserRole? _selectedRole;

  void _handleContinue() {
    if (_selectedRole == null) return;

    ref.read(authProvider.notifier).setRole(_selectedRole!);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen untuk success dan error
    ref.listen(authProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    next.error.toString().replaceAll('Exception: ', ''),
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
          ),
        );
      } else if (next.hasValue) {
        final state = next.value!;
        if (state.status.name == 'authenticated' && state.user?.role != null) {
          // Role berhasil disimpan, redirect ke home
          context.go('/home');
        }
      }
    });

    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Pilih Peran Anda'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Anda akan berkontribusi sebagai:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              const SizedBox(height: 28),
              // Card Penyewa (Renter)
              Expanded(
                child: _RoleCard(
                  title: 'Saya Ingin Menyewa',
                  description:
                      'Temukan dan sewa barang yang Anda butuhkan dengan mudah.',
                  icon: Icons.shopping_bag,
                  color: Theme.of(context).primaryColor,
                  isSelected: _selectedRole == UserRole.renter,
                  onTap: isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedRole = UserRole.renter;
                          });
                        },
                ),
              ),
              const SizedBox(height: 16),
              // Card Pemilik (Owner)
              Expanded(
                child: _RoleCard(
                  title: 'Saya Pemilik Barang',
                  description:
                      'Daftarkan barang Anda dan mulai mendapatkan penghasilan tambahan.',
                  icon: Icons.storefront,
                  color: Colors.green[600] ?? Colors.green,
                  isSelected: _selectedRole == UserRole.owner,
                  onTap: isLoading
                      ? null
                      : () {
                          setState(() {
                            _selectedRole = UserRole.owner;
                          });
                        },
                ),
              ),
              const SizedBox(height: 28),
              // Tombol Lanjutkan
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      (_selectedRole == null || isLoading) ? null : _handleContinue,
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
                      : const Text('Lanjutkan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RoleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? color.withAlpha(20) : Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: isSelected
                  ? Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}