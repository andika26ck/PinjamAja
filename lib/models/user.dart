import 'package:equatable/equatable.dart';

enum UserRole { owner, renter }

extension UserRoleX on UserRole {
  String toDb() => name;

  static UserRole fromDb(String value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => throw ArgumentError('Unknown UserRole: $value'),
    );
  }
}

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    this.avatarUrl,
    this.rating = 0.0,
    this.totalTransactions = 0,
    this.isVerified = false,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final double rating;
  final int totalTransactions;
  final bool isVerified;
  final DateTime createdAt;

  /// CATATAN: tabel `profiles` (lihat schema.sql) TIDAK punya kolom `email`
  /// — email hanya tersimpan di `auth.users`. Saat membangun [User] dari
  /// hasil query `profiles`, gabungkan dulu dengan `session.user.email` di
  /// service/provider pemanggil (mis. sisipkan `'email': session.user.email`
  /// ke map) sebelum memanggil [fromJson]. Belum ditangani otomatis di sini
  /// karena AuthService belum diimplementasikan pada prompt ini.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRoleX.fromDb(json['role'] as String),
      avatarUrl: json['avatar_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'role': role.toDb(),
        'avatar_url': avatarUrl,
        'rating': rating,
        'total_transactions': totalTransactions,
        'is_verified': isVerified,
        'created_at': createdAt.toIso8601String(),
      };

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    UserRole? role,
    String? avatarUrl,
    double? rating,
    int? totalTransactions,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      rating: rating ?? this.rating,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        role,
        avatarUrl,
        rating,
        totalTransactions,
        isVerified,
        createdAt,
      ];
}
