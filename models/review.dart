import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.bookingId,
    required this.itemId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String bookingId;
  final String itemId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final int rating;
  final String comment;
  final DateTime createdAt;

  /// CATATAN: tabel `reviews` di schema.sql TIDAK punya kolom
  /// `reviewer_name`/`reviewer_avatar_url` — keduanya didapat lewat join ke
  /// `profiles`. Query di service nanti perlu bentuk seperti:
  /// `select('*, profiles!reviewer_id(name, avatar_url)')`, lalu hasil join
  /// diratakan ('reviewer_name': row['profiles']['name'], dst.) sebelum
  /// dipassing ke [fromJson].
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      itemId: json['item_id'] as String,
      reviewerId: json['reviewer_id'] as String,
      reviewerName: json['reviewer_name'] as String? ?? 'Pengguna',
      reviewerAvatarUrl: json['reviewer_avatar_url'] as String?,
      rating: (json['rating'] as num).toInt(),
      comment: json['comment'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  /// `reviewer_name`/`reviewer_avatar_url` sengaja TIDAK disertakan — bukan
  /// kolom asli tabel `reviews`, insert dengan field ini akan error.
  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_id': bookingId,
        'item_id': itemId,
        'reviewer_id': reviewerId,
        'rating': rating,
        'comment': comment,
        'created_at': createdAt.toIso8601String(),
      };

  Review copyWith({
    String? id,
    String? bookingId,
    String? itemId,
    String? reviewerId,
    String? reviewerName,
    String? reviewerAvatarUrl,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      itemId: itemId ?? this.itemId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerAvatarUrl: reviewerAvatarUrl ?? this.reviewerAvatarUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        itemId,
        reviewerId,
        reviewerName,
        reviewerAvatarUrl,
        rating,
        comment,
        createdAt,
      ];
}
