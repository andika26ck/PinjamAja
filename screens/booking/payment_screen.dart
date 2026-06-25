import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/price_helper.dart';
import '../../models/booking.dart';
import '../../providers/booking_provider.dart';
import '../../services/booking_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.bookingId});
  final String bookingId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'transfer';
  bool _isSuccess = false;
  bool _isLoading = false;
  String _bookingCode = '';

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);
    try {
      await BookingService.updatePaymentStatus(widget.bookingId, PaymentStatus.paid);
      // Generate random booking code
      final code = 'PJMJ-${(100000 + Random().nextInt(900000)).toString()}';
      setState(() {
        _bookingCode = code;
        _isSuccess = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessView();

    final bookingAsync = ref.watch(bookingDetailProvider(widget.bookingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran')),
      body: bookingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (booking) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Item ID: ${booking.itemId}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text('${booking.totalDays} Hari (${booking.startDate.toString().split(' ')[0]} - ${booking.endDate.toString().split(' ')[0]})'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('Total yang Harus Dibayar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              PriceHelper.formatCurrency(booking.totalPrice),
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(height: 32),

            const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            RadioListTile(
              value: 'transfer',
              groupValue: _selectedMethod,
              onChanged: (val) => setState(() => _selectedMethod = val.toString()),
              title: const Text('Transfer Bank (BCA, Mandiri, BNI)'),
              secondary: const Icon(Icons.account_balance),
            ),
            RadioListTile(
              value: 'ewallet',
              groupValue: _selectedMethod,
              onChanged: (val) => setState(() => _selectedMethod = val.toString()),
              title: const Text('GoPay / OVO'),
              secondary: const Icon(Icons.account_balance_wallet),
            ),
            RadioListTile(
              value: 'card',
              groupValue: _selectedMethod,
              onChanged: (val) => setState(() => _selectedMethod = val.toString()),
              title: const Text('Kartu Kredit / Debit'),
              secondary: const Icon(Icons.credit_card),
            ),
            
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Bayar Sekarang'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 80),
              ),
              const SizedBox(height: 24),
              const Text('Pembayaran Berhasil!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, style: BorderStyle.solid), // Dashed can be done with external package, using solid for simplicity
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Text(_bookingCode, style: const TextStyle(fontSize: 20, letterSpacing: 2, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/history'),
                  child: const Text('Lihat Detail Booking'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}