import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/chat_message.dart';
import '../../providers/chat_providers.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.otherUserId,
    required this.bookingId,
    this.otherUserName,
    this.otherUserAvatar,
    this.itemTitle,
  });

  /// userId lawan bicara — diambil dari path param `/chat/:userId`.
  final String otherUserId;

  /// bookingId — diambil dari query param `?bookingId=`.
  final String bookingId;

  /// Tiga field di bawah ini opsional: diisi lewat `extra` go_router saat
  /// navigasi dari [ChatListScreen] (supaya AppBar bisa render instan tanpa
  /// fetch tambahan). Kalau null (mis. screen dibuka lewat deep link),
  /// AppBar tetap tampil dengan fallback generik.
  final String? otherUserName;
  final String? otherUserAvatar;
  final String? itemTitle;

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _pendingMessages = [];
  bool _hasText = false;
  bool _hasMarkedRead = false;

  String get _currentUserId => Supabase.instance.client.auth.currentUser!.id;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      final hasText = _inputController.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _markAsRead() async {
    if (_hasMarkedRead) return;
    _hasMarkedRead = true;
    try {
      await ref.read(chatServiceProvider).markAsRead(
            widget.otherUserId,
            _currentUserId,
            widget.bookingId,
          );
    } catch (_) {
      // Biarkan retry pada pemanggilan berikutnya kalau gagal.
      _hasMarkedRead = false;
    }
  }

  Future<void> _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();

    // Optimistic update: tampilkan langsung di UI sebelum dikonfirmasi server.
    final optimistic = ChatMessage(
      id: 'temp-${DateTime.now().microsecondsSinceEpoch}',
      senderId: _currentUserId,
      receiverId: widget.otherUserId,
      bookingId: widget.bookingId,
      message: text,
      isRead: false,
      timestamp: DateTime.now(),
    );

    setState(() => _pendingMessages.add(optimistic));
    _scrollToBottom();

    try {
      await ref.read(chatServiceProvider).sendMessage(
            senderId: _currentUserId,
            receiverId: widget.otherUserId,
            bookingId: widget.bookingId,
            message: text,
          );
      // Pesan asli akan masuk lewat Realtime stream; bubble sementara dilepas.
      if (mounted) {
        setState(
          () => _pendingMessages.removeWhere((m) => m.id == optimistic.id),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _pendingMessages.removeWhere((m) => m.id == optimistic.id),
      );
      _inputController.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim pesan. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = chatMessagesProvider(widget.bookingId, _currentUserId);
    final messagesAsync = ref.watch(provider);

    ref.listen(provider, (previous, next) {
      next.whenData((_) {
        _scrollToBottom();
        _markAsRead();
      });
    });

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _Avatar(name: widget.otherUserName, avatarUrl: widget.otherUserAvatar),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.otherUserName ?? 'Pengguna',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.itemTitle != null)
                    Text(
                      widget.itemTitle!,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                final combined = <ChatMessage>[...messages, ..._pendingMessages]
                  ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

                if (combined.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada pesan. Mulai percakapan!',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  itemCount: combined.length,
                  itemBuilder: (context, index) {
                    final msg = combined[index];
                    return _MessageBubble(
                      message: msg,
                      isMe: msg.senderId == _currentUserId,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Center(child: Text('Gagal memuat pesan: $error')),
            ),
          ),
          _InputBar(
            controller: _inputController,
            canSend: _hasText,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.name, this.avatarUrl});

  final String? name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatarUrl != null && avatarUrl!.isNotEmpty;
    return CircleAvatar(
      radius: 18,
      backgroundColor: Colors.grey[300],
      backgroundImage: hasAvatar ? CachedNetworkImageProvider(avatarUrl!) : null,
      child: !hasAvatar
          ? Text((name?.isNotEmpty ?? false) ? name![0].toUpperCase() : '?')
          : null,
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool canSend;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Ketik pesan...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send_rounded),
              color: canSend
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[400],
              onPressed: canSend ? onSend : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMe});

  final ChatMessage message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:mm').format(message.timestamp);
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
