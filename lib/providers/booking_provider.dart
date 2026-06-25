import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/booking.dart';
import '../services/booking_service.dart';

part 'booking_provider.g.dart';

@riverpod
Future<Booking> bookingDetail(BookingDetailRef ref, String bookingId) {
  return BookingService.getById(bookingId);
}

@riverpod
class RenterBookings extends _$RenterBookings {
  @override
  Future<List<Booking>> build(String renterId) {
    return BookingService.getByRenter(renterId);
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => BookingService.getByRenter(renterId));
  }
}

@riverpod
class OwnerBookings extends _$OwnerBookings {
  @override
  Future<List<Booking>> build(String ownerId) {
    return BookingService.getByOwner(ownerId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => BookingService.getByOwner(ownerId));
  }
}