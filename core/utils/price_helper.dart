import 'package:intl/intl.dart';

/// Util kalkulasi & format harga.
///
/// Belum diminta eksplisit di Prompt #1 (file ini awalnya "kosong" di
/// struktur folder), tapi diisi sekarang karena formula platform fee &
/// total price SUDAH dispesifikasikan langsung di komentar model [Booking]
/// — daripada formula 5% itu tercecer di banyak tempat saat booking dibuat
/// nanti, lebih aman dipusatkan di sini dari awal.
class PriceHelper {
  PriceHelper._();

  static const double platformFeeRate = 0.05; // 5%

  static double calculatePlatformFee(int totalDays, double pricePerDay) {
    return totalDays * pricePerDay * platformFeeRate;
  }

  static double calculateTotalPrice({
    required int totalDays,
    required double pricePerDay,
    required double depositAmount,
  }) {
    final rentalCost = totalDays * pricePerDay;
    final platformFee = calculatePlatformFee(totalDays, pricePerDay);
    return rentalCost + depositAmount + platformFee;
  }

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static String formatCurrency(double amount) => _currencyFormat.format(amount);
}
