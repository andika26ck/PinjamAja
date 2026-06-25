import '../core/config/supabase_config.dart';
import '../core/errors/app_exception.dart';
import '../models/booking.dart';
import '../models/review.dart';

class BookingService {
  const BookingService._();
  static final _client = SupabaseConfig.client;

  static Future<Booking> create({
    required String itemId,
    required String renterId,
    required String ownerId,
    required DateTime startDate,
    required DateTime endDate,
    required double pricePerDay,
    required double depositAmount,
    required double platformFee,
    required double totalPrice,
    String? note,
  }) async {
    try {
      final response = await _client.from('bookings').insert({
        'item_id': itemId,
        'renter_id': renterId,
        'owner_id': ownerId,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'price_per_day': pricePerDay,
        'deposit_amount': depositAmount,
        'platform_fee': platformFee,
        'total_price': totalPrice,
        'status': 'pending',
        'payment_status': 'unpaid',
        // Opsional: simpan note jika ada kolomnya di DB. 
        // Jika tidak ada di skema awal, bisa diabaikan atau ditambahkan.
      }).select().single();
      
      return Booking.fromJson(response);
    } catch (e) {
      throw AppException(message: 'Gagal membuat booking: $e', originalError: e);
    }
  }

  static Future<List<Booking>> getByRenter(String renterId) async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('renter_id', renterId)
          .order('created_at', ascending: false);
      return (response as List).map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      throw AppException(message: 'Gagal mengambil data booking', originalError: e);
    }
  }

  static Future<List<Booking>> getByOwner(String ownerId) async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('owner_id', ownerId)
          .order('created_at', ascending: false);
      return (response as List).map((json) => Booking.fromJson(json)).toList();
    } catch (e) {
      throw AppException(message: 'Gagal mengambil data pesanan', originalError: e);
    }
  }

  static Future<Booking> getById(String bookingId) async {
    try {
      final response = await _client
          .from('bookings')
          .select()
          .eq('id', bookingId)
          .single();
      return Booking.fromJson(response);
    } catch (e) {
      throw AppException(message: 'Data booking tidak ditemukan', originalError: e);
    }
  }

  static Future<void> updateStatus(String bookingId, BookingStatus status) async {
    try {
      await _client
          .from('bookings')
          .update({'status': status.toDb()})
          .eq('id', bookingId);
    } catch (e) {
      throw AppException(message: 'Gagal update status booking', originalError: e);
    }
  }

  static Future<void> updatePaymentStatus(String bookingId, PaymentStatus status) async {
    try {
      await _client
          .from('bookings')
          .update({
            'payment_status': status.toDb(),
            // Jika dibayar, otomatis confirmed
            if (status == PaymentStatus.paid) 'status': BookingStatus.confirmed.toDb()
          })
          .eq('id', bookingId);
    } catch (e) {
      throw AppException(message: 'Gagal update status pembayaran', originalError: e);
    }
  }

  static Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      await _client.from('bookings').update({
        'status': BookingStatus.cancelled.toDb(),
        'cancellation_reason': reason,
      }).eq('id', bookingId);
    } catch (e) {
      throw AppException(message: 'Gagal membatalkan booking', originalError: e);
    }
  }

  static Future<Review> createReview({
    required String bookingId,
    required String itemId,
    required int rating,
    required String comment,
  }) async {
    try {
      final session = _client.auth.currentSession;
      final reviewerId = session!.user.id;
      final response = await _client.from('reviews').insert({
        'booking_id': bookingId,
        'item_id': itemId,
        'reviewer_id': reviewerId,
        'rating': rating,
        'comment': comment,
      }).select('*, profiles!reviewer_id(name, avatar_url)').single();
      
      final data = response as Map<String, dynamic>;
      final profile = data['profiles'] as Map<String, dynamic>?;
      return Review.fromJson({
        ...data,
        'reviewer_name': profile?['name'] ?? 'Pengguna',
        'reviewer_avatar_url': profile?['avatar_url'],
      });
    } catch (e) {
      throw AppException(message: 'Gagal mengirim ulasan', originalError: e);
    }
  }
}