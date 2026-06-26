import 'package:equatable/equatable.dart';

enum BookingStatus { pending, confirmed, active, completed, cancelled }

extension BookingStatusX on BookingStatus {
  String toDb() => name;

  static BookingStatus fromDb(String value) {
    return BookingStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => throw ArgumentError('Unknown BookingStatus: $value'),
    );
  }
}

enum PaymentStatus { unpaid, paid, refunded }

extension PaymentStatusX on PaymentStatus {
  String toDb() => name;

  static PaymentStatus fromDb(String value) {
    return PaymentStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => throw ArgumentError('Unknown PaymentStatus: $value'),
    );
  }
}

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.itemId,
    required this.renterId,
    required this.ownerId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.pricePerDay,
    this.depositAmount = 0,
    required this.platformFee,
    required this.totalPrice,
    this.status = BookingStatus.pending,
    this.paymentStatus = PaymentStatus.unpaid,
    this.cancellationReason,
    required this.createdAt,
  });

  final String id;
  final String itemId;
  final String renterId;
  final String ownerId;
  final DateTime startDate;
  final DateTime endDate;

  /// `endDate.difference(startDate).inDays`. Di DB ini kolom GENERATED
  /// (read-only) — jangan dikirim balik saat INSERT (lihat [toJson]).
  final int totalDays;
  final double pricePerDay;
  final double depositAmount;

  /// 5% dari (totalDays × pricePerDay). Lihat `PriceHelper.calculatePlatformFee`.
  final double platformFee;

  /// (totalDays × pricePerDay) + depositAmount + platformFee.
  /// Lihat `PriceHelper.calculateTotalPrice`.
  final double totalPrice;
  final BookingStatus status;
  final PaymentStatus paymentStatus;
  final String? cancellationReason;
  final DateTime createdAt;

  factory Booking.fromJson(Map<String, dynamic> json) {
    final start = DateTime.parse(json['start_date'] as String);
    final end = DateTime.parse(json['end_date'] as String);
    return Booking(
      id: json['id'] as String,
      itemId: json['item_id'] as String,
      renterId: json['renter_id'] as String,
      ownerId: json['owner_id'] as String,
      startDate: start,
      endDate: end,
      totalDays:
          (json['total_days'] as num?)?.toInt() ?? end.difference(start).inDays,
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0,
      platformFee: (json['platform_fee'] as num).toDouble(),
      totalPrice: (json['total_price'] as num).toDouble(),
      status: BookingStatusX.fromDb(json['status'] as String? ?? 'pending'),
      paymentStatus:
          PaymentStatusX.fromDb(json['payment_status'] as String? ?? 'unpaid'),
      cancellationReason: json['cancellation_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// `total_days` sengaja TIDAK disertakan — kolom GENERATED di Postgres,
  /// insert/update dengan kolom ini akan error.
  Map<String, dynamic> toJson() => {
        'id': id,
        'item_id': itemId,
        'renter_id': renterId,
        'owner_id': ownerId,
        'start_date': startDate.toIso8601String().split('T').first,
        'end_date': endDate.toIso8601String().split('T').first,
        'price_per_day': pricePerDay,
        'deposit_amount': depositAmount,
        'platform_fee': platformFee,
        'total_price': totalPrice,
        'status': status.toDb(),
        'payment_status': paymentStatus.toDb(),
        'cancellation_reason': cancellationReason,
        'created_at': createdAt.toIso8601String(),
      };

  Booking copyWith({
    String? id,
    String? itemId,
    String? renterId,
    String? ownerId,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    double? pricePerDay,
    double? depositAmount,
    double? platformFee,
    double? totalPrice,
    BookingStatus? status,
    PaymentStatus? paymentStatus,
    String? cancellationReason,
    DateTime? createdAt,
  }) {
    return Booking(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      renterId: renterId ?? this.renterId,
      ownerId: ownerId ?? this.ownerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      depositAmount: depositAmount ?? this.depositAmount,
      platformFee: platformFee ?? this.platformFee,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        itemId,
        renterId,
        ownerId,
        startDate,
        endDate,
        totalDays,
        pricePerDay,
        depositAmount,
        platformFee,
        totalPrice,
        status,
        paymentStatus,
        cancellationReason,
        createdAt,
      ];
}
