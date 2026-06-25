import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/chat_message.dart';
import '../services/chat_service.dart';

part 'chat_providers.g.dart';

// NOTE: file ini memakai riverpod_annotation (sesuai stack reference).
// Setelah menyalin file ini ke project, jalankan:
//   dart run build_runner build --delete-conflicting-outputs
// untuk men-generate `chat_providers.g.dart`.

@riverpod
ChatService chatService(ChatServiceRef ref) {
  return ChatService(Supabase.instance.client);
}

@riverpod
Future<List<Map<String, dynamic>>> conversationList(
  ConversationListRef ref,
  String userId,
) {
  return ref.watch(chatServiceProvider).getConversationList(userId);
}

@riverpod
Stream<List<ChatMessage>> chatMessages(
  ChatMessagesRef ref,
  String bookingId,
  String currentUserId,
) async* {
  final service = ref.watch(chatServiceProvider);
  yield* service.subscribeToMessages(
    bookingId: bookingId,
    currentUserId: currentUserId,
  );
}
