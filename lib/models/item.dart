import 'package:equatable/equatable.dart';

enum ItemCondition { baru, sangatBaik, baik, cukup }

extension ItemConditionX on ItemCondition {
  String toDb() {
    switch (this) {
      case ItemCondition.baru:
        return 'baru';
      case ItemCondition.sangatBaik:
        return 'sangat_baik';
      case ItemCondition.baik:
        return 'baik';
      case ItemCondition.cukup:
        return 'cukup';
    }
  }

  String get display {
    switch (this) {
      case ItemCondition.baru:
        return 'Baru';
      case ItemCondition.sangatBaik:
        return 'Sangat Baik';
      case ItemCondition.baik:
        return 'Baik';
      case ItemCondition.cukup:
        return 'Cukup';
    }
  }

  static ItemCondition fromDb(String value) {
    switch (value) {
      case 'baru':
        return ItemCondition.baru;
      case 'sangat_baik':
        return ItemCondition.sangatBaik;
      case 'baik':
        return ItemCondition.baik;
      case 'cukup':
        return ItemCondition.cukup;
      default:
        throw ArgumentError('Unknown ItemCondition: $value');
    }
  }
}

enum ItemStatus { available, unavailable, rented }

extension ItemStatusX on ItemStatus {
  String toDb() => name;

  static ItemStatus fromDb(String value) {
    return ItemStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => throw ArgumentError('Unknown ItemStatus: $value'),
    );
  }
}

class Item extends Equatable {
  const Item({
    required this.id,
    required this.ownerId,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.pricePerDay,
    this.depositAmount = 0,
    this.imageUrls = const [],
    required this.condition,
    this.status = ItemStatus.available,
    required this.location,
    this.latitude,
    this.longitude,
    this.blockedDates = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String categoryId;
  final String title;
  final String description;
  final double pricePerDay;
  final double depositAmount;
  final List<String> imageUrls;
  final ItemCondition condition;
  final ItemStatus status;
  final String location;
  final double? latitude;
  final double? longitude;
  final List<DateTime> blockedDates;
  final double rating;
  final int totalReviews;
  final DateTime createdAt;

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pricePerDay: (json['price_per_day'] as num).toDouble(),
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0,
      imageUrls: (json['image_urls'] as List?)?.cast<String>() ?? const [],
      condition: ItemConditionX.fromDb(json['condition'] as String),
      status: ItemStatusX.fromDb(json['status'] as String? ?? 'available'),
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      blockedDates: (json['blocked_dates'] as List?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['total_reviews'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'owner_id': ownerId,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'price_per_day': pricePerDay,
        'deposit_amount': depositAmount,
        'image_urls': imageUrls,
        'condition': condition.toDb(),
        'status': status.toDb(),
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'blocked_dates':
            blockedDates.map((d) => d.toIso8601String().split('T').first).toList(),
        'rating': rating,
        'total_reviews': totalReviews,
        'created_at': createdAt.toIso8601String(),
      };

  Item copyWith({
    String? id,
    String? ownerId,
    String? categoryId,
    String? title,
    String? description,
    double? pricePerDay,
    double? depositAmount,
    List<String>? imageUrls,
    ItemCondition? condition,
    ItemStatus? status,
    String? location,
    double? latitude,
    double? longitude,
    List<DateTime>? blockedDates,
    double? rating,
    int? totalReviews,
    DateTime? createdAt,
  }) {
    return Item(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      depositAmount: depositAmount ?? this.depositAmount,
      imageUrls: imageUrls ?? this.imageUrls,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      blockedDates: blockedDates ?? this.blockedDates,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        categoryId,
        title,
        description,
        pricePerDay,
        depositAmount,
        imageUrls,
        condition,
        status,
        location,
        latitude,
        longitude,
        blockedDates,
        rating,
        totalReviews,
        createdAt,
      ];
}
