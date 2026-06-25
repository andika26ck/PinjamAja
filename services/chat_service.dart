import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';

/// Semua akses data chat (Supabase) terpusat di sini.
///
/// Catatan desain:
/// - `subscribeToMessages` memfilter Realtime channel hanya dengan
///   `booking_id`, karena filter Postgres Changes Supabase hanya mendukung
///   satu kondisi equality (tidak ada OR). Karena satu booking hanya
///   melibatkan 2 pihak (renter & owner), dan RLS sudah membatasi baris yang
///   bisa dibaca user ke pesan yang ia kirim/terima, ini aman & cukup.
/// - `getConversationList` memanggil RPC `get_conversations()` yang TIDAK
///   menerima parameter user id dari client — function tersebut memakai
///   `auth.uid()` di sisi database, supaya user A tidak bisa memanggil RPC
///   dengan id user B untuk membaca daftar percakapan orang lain.
class ChatService {
  ChatService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Ambil [limit] pesan terbaru pada satu booking, dikembalikan dalam
  /// urutan ascending (lama -> baru) supaya siap dirender langsung.
  Future<List<ChatMessage>> getMessages({
    required String bookingId,
    int limit = 50,
  }) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('booking_id', bookingId)
        .order('timestamp', ascending: false)
        .limit(limit);

    return (data as List)
        .map((row) => ChatMessage.fromJson(row as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }

  Future<ChatMessage> sendMessage({
    required String senderId,
    required String receiverId,
    required String bookingId,
    required String message,
  }) async {
    final data = await _client
        .from('messages')
        .insert({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'booking_id': bookingId,
          'message': message,
        })
        .select()
        .single();

    return ChatMessage.fromJson(data);
  }

  /// Tandai pesan yang dikirim [senderId] kepada [receiverId] pada
  /// [bookingId] sebagai sudah dibaca. Dipanggil saat [receiverId] (current
  /// user) membuka ruang chat tersebut.
  Future<void> markAsRead(
    String senderId,
    String receiverId,
    String bookingId,
  ) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', senderId)
        .eq('receiver_id', receiverId)
        .eq('booking_id', bookingId)
        .eq('is_read', false);
  }

  /// Stream daftar pesan (snapshot penuh, terurut ascending) untuk satu
  /// booking. Emisi pertama berisi histori (lewat [getMessages]), emisi
  /// berikutnya ter-update setiap kali ada INSERT/UPDATE baru lewat Realtime.
  ///
  /// Channel otomatis di-`removeChannel` saat stream di-cancel (mis. saat
  /// `ref.watch` di provider berhenti di-watch / screen di-dispose).
  Stream<List<ChatMessage>> subscribeToMessages({
    required String bookingId,
    required String currentUserId,
  }) {
    late final StreamController<List<ChatMessage>> controller;
    var current = <ChatMessage>[];
    RealtimeChannel? channel;

    Future<void> loadInitial() async {
      current = await getMessages(bookingId: bookingId);
      if (!controller.isClosed) controller.add(List.unmodifiable(current));
    }

    void upsert(ChatMessage incoming) {
      final idx = current.indexWhere((m) => m.id == incoming.id);
      if (idx == -1) {
        current = [...current, incoming]
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
      } else {
        current = [...current]..[idx] = incoming;
      }
      if (!controller.isClosed) controller.add(List.unmodifiable(current));
    }

    controller = StreamController<List<ChatMessage>>(
      onListen: () {
        loadInitial();
        channel = _client
            .channel('messages:booking_id=$bookingId')
            .onPostgresChanges(
              event: PostgresChangeEvent.insert,
              schema: 'public',
              table: 'messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'booking_id',
                value: bookingId,
              ),
              callback: (payload) {
                upsert(ChatMessage.fromJson(payload.newRecord));
              },
            )
            .onPostgresChanges(
              event: PostgresChangeEvent.update,
              schema: 'public',
              table: 'messages',
              filter: PostgresChangeFilter(
                type: PostgresChangeFilterType.eq,
                column: 'booking_id',
                value: bookingId,
              ),
              callback: (payload) {
                upsert(ChatMessage.fromJson(payload.newRecord));
              },
            )
            .subscribe();
      },
      onCancel: () {
        final ch = channel;
        if (ch != null) _client.removeChannel(ch);
      },
    );

    return controller.stream;
  }

  /// Daftar percakapan unik milik [userId] (di-group by booking_id + lawan
  /// bicara), terurut dari pesan terbaru. Setiap item berisi:
  /// booking_id, other_user_id, other_user_name, other_user_avatar,
  /// item_id, item_title, last_message, last_message_time, unread_count.
  ///
  /// [userId] tidak dikirim ke RPC (lihat catatan desain di atas) — wajib
  /// tetap sama dengan `auth.uid()` milik sesi yang sedang login.
  Future<List<Map<String, dynamic>>> getConversationList(String userId) async {
    final data = await _client.rpc('get_conversations');
    return (data as List).cast<Map<String, dynamic>>();
  }
}
