import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../core/utils/price_helper.dart';
import '../../models/item.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../services/booking_service.dart';

class BookingFormScreen extends ConsumerStatefulWidget {
  const BookingFormScreen({super.key, required this.itemId});
  final String itemId;

  @override
  ConsumerState<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends ConsumerState<BookingFormScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  bool _isDateBlocked(DateTime day, List<DateTime> blockedDates) {
    return blockedDates.any((d) => isSameDay(d, day));
  }

  bool _isRangeValid(DateTime start, DateTime end, List<DateTime> blockedDates) {
    for (DateTime d = start; d.isBefore(end.add(const Duration(days: 1))); d = d.add(const Duration(days: 1))) {
      if (_isDateBlocked(d, blockedDates)) return false;
    }
    return true;
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay, List<DateTime> blockedDates) {
    if (start != null && end != null) {
      if (!_isRangeValid(start, end, blockedDates)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terdapat tanggal yang tidak tersedia pada rentang yang dipilih.')),
        );
        setState(() {
          _rangeStart = null;
          _rangeEnd = null;
        });
        return;
      }
    }
    setState(() {
      _rangeStart = start;
      _rangeEnd = end;
      _focusedDay = focusedDay;
    });
  }

  Future<void> _submitBooking(Item item, String renterId) async {
    if (_rangeStart == null || _rangeEnd == null) return;
    setState(() => _isLoading = true);
    
    final totalDays = _rangeEnd!.difference(_rangeStart!).inDays + 1; // +1 if same day counts as 1 day, adjust based on logic
    final subtotal = totalDays * item.pricePerDay;
    final platformFee = PriceHelper.calculatePlatformFee(totalDays, item.pricePerDay);
    final totalPrice = PriceHelper.calculateTotalPrice(
      totalDays: totalDays, pricePerDay: item.pricePerDay, depositAmount: item.depositAmount,
    );

    try {
      final booking = await BookingService.create(
        itemId: item.id,
        renterId: renterId,
        ownerId: item.ownerId,
        startDate: _rangeStart!,
        endDate: _rangeEnd!,
        pricePerDay: item.pricePerDay,
        depositAmount: item.depositAmount,
        platformFee: platformFee,
        totalPrice: totalPrice,
        note: _noteController.text,
      );
      if (mounted) context.go('/payment/${booking.id}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemAsync = ref.watch(itemDetailProvider(widget.itemId));
    final user = ref.watch(authProvider).valueOrNull?.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Form Sewa')),
      body: itemAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (item) {
          int totalDays = 0;
          double subtotal = 0;
          double platformFee = 0;
          double totalPrice = 0;

          if (_rangeStart != null && _rangeEnd != null) {
             // +1 as inclusive rental (e.g. 1st to 2nd is 2 days) - adjust if necessary
            totalDays = _rangeEnd!.difference(_rangeStart!).inDays + 1;
            if(totalDays < 1) totalDays = 1;
            subtotal = totalDays * item.pricePerDay;
            platformFee = PriceHelper.calculatePlatformFee(totalDays, item.pricePerDay);
            totalPrice = PriceHelper.calculateTotalPrice(
              totalDays: totalDays, pricePerDay: item.pricePerDay, depositAmount: item.depositAmount
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Info Item
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrls.isNotEmpty ? item.imageUrls.first : 'https://via.placeholder.com/150',
                      width: 80, height: 80, fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Pemilik ID: ${item.ownerId}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              const Divider(height: 32),
              
              // 2. Kalender
              const Text('Pilih Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TableCalendar(
                firstDay: DateTime.now(),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                rangeStartDay: _rangeStart,
                rangeEndDay: _rangeEnd,
                calendarFormat: CalendarFormat.month,
                rangeSelectionMode: RangeSelectionMode.toggledOn,
                onRangeSelected: (start, end, focusedDay) => _onRangeSelected(start, end, focusedDay, item.blockedDates),
                enabledDayPredicate: (day) => !_isDateBlocked(day, item.blockedDates),
                calendarStyle: CalendarStyle(
                  rangeHighlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
                  rangeStartDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                  rangeEndDecoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
                ),
              ),
              const Divider(height: 32),

              // 3. Ringkasan Harga
              const Text('Ringkasan Harga', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              if (_rangeStart != null && _rangeEnd != null) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Sewa ($totalDays hari)'), Text(PriceHelper.formatCurrency(subtotal))],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Deposit (Refundable)'), Text(PriceHelper.formatCurrency(item.depositAmount))],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Biaya Platform (5%)'), Text(PriceHelper.formatCurrency(platformFee))],
                ),
                const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text(PriceHelper.formatCurrency(totalPrice), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Deposit dikembalikan setelah barang kembali.', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic)),
              ] else
                const Text('Pilih tanggal untuk melihat harga', style: TextStyle(color: Colors.grey)),
              
              const Divider(height: 32),
              
              // 4. Catatan
              const Text('Catatan untuk Pemilik (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _noteController,
                maxLength: 200,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Cth: Saya ambil barang jam 9 pagi ya...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 24),

              // 5. Submit Button
              ElevatedButton(
                onPressed: (_rangeStart != null && _rangeEnd != null && !_isLoading && user != null)
                    ? () => _submitBooking(item, user.id)
                    : null,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Lanjut ke Pembayaran'),
              ),
              const SizedBox(height: 24),
            ],
          );
        }
      ),
    );
  }
}