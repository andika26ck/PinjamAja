import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/price_helper.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/booking_service.dart';
import '../../widgets/common/empty_state.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final roleAsync = ref.watch(currentUserRoleProvider);
    final user = ref.watch(authProvider).valueOrNull?.user;

    if (user == null || !roleAsync.hasValue) {
      return Scaffold(appBar: AppBar(title: const Text('Riwayat')), body: const Center(child: CircularProgressIndicator()));
    }

    final isOwner = roleAsync.value == 'owner';
    if (!isOwner) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Sewa')),
        body: _RenterTab(userId: user.id),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riwayat'),
          bottom: const TabBar(tabs: [Tab(text: 'Sebagai Penyewa'), Tab(text: 'Sebagai Pemilik')]),
        ),
        body: TabBarView(
          children: [_RenterTab(userId: user.id), _OwnerTab(userId: user.id)],
        ),
      ),
    );
  }
}

class _RenterTab extends ConsumerWidget {
  final String userId;
  const _RenterTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(renterBookingsProvider(userId));
    return RefreshIndicator(
      onRefresh: () => ref.read(renterBookingsProvider(userId).notifier).refresh(),
      child: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(title: 'Error', message: 'Gagal: $e', icon: Icons.error),
        data: (bookings) {
          if (bookings.isEmpty) {
            return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: const EmptyState(title: 'Belum ada riwayat', message: 'Anda belum melakukan penyewaan barang.', icon: Icons.receipt_long)),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('Booking #${b.id.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        _StatusBadge(status: b.status),
                      ]),
                      const SizedBox(height: 8),
                      Text('Tanggal: ${b.startDate.toString().split(' ')[0]} s/d ${b.endDate.toString().split(' ')[0]}'),
                      Text('Total: ${PriceHelper.formatCurrency(b.totalPrice)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      if (b.status == BookingStatus.completed) ...[
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: () => _showReviewSheet(context, ref, b), child: const Text('Beri Ulasan')),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref, Booking booking) { /* logic review sama seperti sebelumnya */ }
}

class _OwnerTab extends ConsumerWidget {
  final String userId;
  const _OwnerTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(ownerBookingsProvider(userId));
    return RefreshIndicator(
      onRefresh: () => ref.read(ownerBookingsProvider(userId).notifier).refresh(),
      child: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => EmptyState(title: 'Error', message: 'Gagal: $e', icon: Icons.error),
        data: (bookings) {
          if (bookings.isEmpty) {
            return ListView(physics: const AlwaysScrollableScrollPhysics(), children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.6, child: const EmptyState(title: 'Belum ada pesanan', message: 'Belum ada penyewa yang memesan barang Anda.', icon: Icons.inbox)),
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Penyewa: ${b.renterId.substring(0,6)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (b.status == BookingStatus.pending) Row(children: [
                      Expanded(child: OutlinedButton(onPressed: () => _updateStatus(context, ref, b.id, BookingStatus.cancelled), child: const Text('Tolak'))),
                      const SizedBox(width: 12),
                      Expanded(child: ElevatedButton(onPressed: () => _updateStatus(context, ref, b.id, BookingStatus.confirmed), child: const Text('Terima'))),
                    ])
                  ]),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String id, BookingStatus newStatus) async { /* ... */ }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});
  @override
  Widget build(BuildContext context) { /* ... sama seperti sebelumnya ... */ return Container(); }
}