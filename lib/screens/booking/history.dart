import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/price_helper.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import '../../services/booking_service.dart';

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

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bookings) {
        if (bookings.isEmpty) return _buildEmpty('Belum ada riwayat pesanan', Icons.receipt_long);
        
        return RefreshIndicator(
          onRefresh: () => ref.read(renterBookingsProvider(userId).notifier).refresh(),
          child: ListView.builder(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ID Item: ${b.itemId.substring(0, 8)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _StatusBadge(status: b.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Tanggal: ${b.startDate.toString().split(' ')[0]} s/d ${b.endDate.toString().split(' ')[0]}'),
                      const SizedBox(height: 8),
                      Text('Total: ${PriceHelper.formatCurrency(b.totalPrice)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      if (b.status == BookingStatus.completed) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showReviewSheet(context, ref, b),
                            child: const Text('Beri Ulasan'),
                          ),
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref, Booking booking) {
    int rating = 5;
    final txt = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16, border: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Berikan Ulasan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) => IconButton(
                  icon: Icon(index < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
                  onPressed: () => setModalState(() => rating = index + 1),
                )),
              ),
              TextField(
                controller: txt,
                maxLines: 3,
                decoration: const InputDecoration(hintText: 'Tuliskan pengalaman Anda...'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  try {
                    await BookingService.createReview(bookingId: booking.id, itemId: booking.itemId, rating: rating, comment: txt.text);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan berhasil dikirim')));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('Kirim Ulasan'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      )
    );
  }
}

class _OwnerTab extends ConsumerWidget {
  final String userId;
  const _OwnerTab({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(ownerBookingsProvider(userId));

    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (bookings) {
        if (bookings.isEmpty) return _buildEmpty('Belum ada pesanan masuk', Icons.inbox);
        
        return RefreshIndicator(
          onRefresh: () => ref.read(ownerBookingsProvider(userId).notifier).refresh(),
          child: ListView.builder(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Penyewa: ${b.renterId.substring(0,6)}...', style: const TextStyle(fontWeight: FontWeight.bold)),
                          _StatusBadge(status: b.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Tanggal: ${b.startDate.toString().split(' ')[0]} s/d ${b.endDate.toString().split(' ')[0]}'),
                      if (b.status == BookingStatus.pending) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: OutlinedButton(
                              onPressed: () => _updateStatus(context, ref, b.id, BookingStatus.cancelled), 
                              child: const Text('Tolak')
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: ElevatedButton(
                              onPressed: () => _updateStatus(context, ref, b.id, BookingStatus.confirmed), 
                              child: const Text('Terima')
                            )),
                          ],
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }

  Future<void> _updateStatus(BuildContext context, WidgetRef ref, String id, BookingStatus newStatus) async {
    try {
      await BookingService.updateStatus(id, newStatus);
      ref.read(ownerBookingsProvider(userId).notifier).refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}

Widget _buildEmpty(String text, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        Text(text, style: const TextStyle(color: Colors.grey, fontSize: 16)),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case BookingStatus.pending: color = Colors.orange; break;
      case BookingStatus.confirmed: color = Colors.blue; break;
      case BookingStatus.active: color = Colors.green; break;
      case BookingStatus.completed: color = Colors.teal; break;
      case BookingStatus.cancelled: color = Colors.red; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.name.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}