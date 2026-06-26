  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:go_router/go_router.dart';
  import 'package:supabase_flutter/supabase_flutter.dart';
  import 'package:timeago/timeago.dart' as timeago;

  import '../../providers/chat_providers.dart';

  class ChatListScreen extends ConsumerWidget {
    const ChatListScreen({super.key});

    String get _currentUserId => Supabase.instance.client.auth.currentUser!.id;

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final userId = _currentUserId;
      final conversationsAsync = ref.watch(conversationListProvider(userId));

      return Scaffold(
        appBar: AppBar(title: const Text('Pesan')),
        body: conversationsAsync.when(
          data: (conversations) {
            if (conversations.isEmpty) {
              return const _EmptyState();
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(conversationListProvider(userId));
                await ref.read(conversationListProvider(userId).future);
              },
              child: ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (context, index) {
                  return _ConversationTile(data: conversations[index]);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text('Gagal memuat percakapan: $error'),
          ),
        ),
      );
    }
  }

  class _EmptyState extends StatelessWidget {
    const _EmptyState();

    @override
    Widget build(BuildContext context) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Belum ada percakapan. Mulai chat dengan pemilik barang!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }
  }

  class _ConversationTile extends StatelessWidget {
    const _ConversationTile({required this.data});

    final Map<String, dynamic> data;

    @override
    Widget build(BuildContext context) {
      final otherUserId = data['other_user_id'] as String;
      final otherUserName = data['other_user_name'] as String? ?? 'Pengguna';
      final otherUserAvatar = data['other_user_avatar'] as String?;
      final itemTitle = data['item_title'] as String? ?? 'Item tidak tersedia';
      final lastMessage = data['last_message'] as String? ?? '';
      final lastMessageTime = data['last_message_time'] != null
          ? DateTime.parse(data['last_message_time'] as String).toLocal()
          : null;
      final unreadCount = (data['unread_count'] as num?)?.toInt() ?? 0;
      final bookingId = data['booking_id'] as String;
      final hasAvatar = otherUserAvatar != null && otherUserAvatar.isNotEmpty;

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: Colors.grey[300],
          backgroundImage:
              hasAvatar ? CachedNetworkImageProvider(otherUserAvatar) : null,
          child: !hasAvatar
              ? Text(otherUserName.isNotEmpty
                  ? otherUserName[0].toUpperCase()
                  : '?')
              : null,
        ),
        title: Text(
          otherUserName,
          style: const TextStyle(fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              itemTitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unreadCount > 0 ? Colors.black87 : Colors.grey[600],
                fontWeight:
                    unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lastMessageTime != null)
              Text(
                timeago.format(lastMessageTime, locale: 'id'),
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
            const SizedBox(height: 6),
            if (unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount > 9 ? '9+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        onTap: () {
          context.push(
            '/chat/$otherUserId?bookingId=$bookingId',
            extra: {
              'otherUserName': otherUserName,
              'otherUserAvatar': otherUserAvatar,
              'itemTitle': itemTitle,
            },
          );
        },
      );
    }
  }
