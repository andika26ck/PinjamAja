import 'package:equatable/equatable.dart';

/// Model untuk satu baris pada tabel `messages` di Supabase.
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.bookingId,
    required this.message,
    required this.isRead,
    required this.timestamp,
  });

  final String id;
  final String senderId;
  final String receiverId;
  final String bookingId;
  final String message;
  final bool isRead;
  final DateTime timestamp;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      bookingId: json['booking_id'] as String,
      message: json['message'] as String,
      isRead: json['is_read'] as bool? ?? false,
      timestamp: DateTime.parse(json['timestamp'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'booking_id': bookingId,
        'message': message,
        'is_read': isRead,
        'timestamp': timestamp.toIso8601String(),
      };

  ChatMessage copyWith({bool? isRead}) {
    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      bookingId: bookingId,
      message: message,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp,
    );
  }

  @override
  List<Object?> get props =>
      [id, senderId, receiverId, bookingId, message, isRead, timestamp];
}
