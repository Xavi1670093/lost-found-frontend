import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unilost_found/core/localization/app_strings.dart';
import 'package:unilost_found/core/services/error_handler.dart';
import 'package:unilost_found/shared/utils/app_notifications.dart';
import 'package:unilost_found/shared/utils/image_utils.dart';
import 'package:unilost_found/shared/widgets/skeleton_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:unilost_found/core/services/custom_cache_manager.dart';
import '../../data/models/chat_model.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final ChatModel chat;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.chat,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  Future<void> _sendMessage(String text) async {
    final t = AppStrings.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final messageRef = FirebaseDatabase.instance
          .ref('messages/${widget.chatId}')
          .push();

      await messageRef.set({
        'id': messageRef.key,
        'sender_id': user.uid,
        'text': text,
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      if (!mounted) return;
      final message = ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, message);
    }
  }

  Future<void> _sendImage(File file) async {
    final t = AppStrings.of(context);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final messageRef = FirebaseDatabase.instance
          .ref('messages/${widget.chatId}')
          .push();

      final messageId = messageRef.key;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('chats/${widget.chatId}/$messageId.webp');

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/webp'),
      );

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      await messageRef.set({
        'id': messageId,
        'sender_id': user.uid,
        'text': '',
        'imageUrl': imageUrl,
        'messageType': 'image',
        'timestamp': ServerValue.timestamp,
      });
    } catch (e) {
      if (!mounted) return;
      final message = ErrorHandler.getMessage(e, t);
      AppNotifications.showError(context, message);
      rethrow;
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final postTitle = widget.chat.postTitle.isNotEmpty ? widget.chat.postTitle : t.defaultItemTitle;
    final otherUserPhoto = widget.chat.getOtherUserPhoto();
    final otherUserName = widget.chat.getOtherUserName(t.defaultUserName);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
              child: ClipOval(
                child: otherUserPhoto != null && otherUserPhoto.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: otherUserPhoto,
                        cacheManager: CustomCacheManager.instance,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SkeletonLoader(
                          width: 40,
                          height: 40,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 24),
                      )
                    : Icon(Icons.person_rounded, color: theme.colorScheme.primary, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherUserName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    postTitle,
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref('messages/${widget.chatId}')
                  .orderByChild('timestamp')
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: theme.colorScheme.outline),
                        const SizedBox(height: 16),
                        Text(t.noMessagesYetDetail, style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  );
                }

                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final messages = data.values
                    .map((e) => Map<dynamic, dynamic>.from(e as Map))
                    .toList();

                messages.sort(
                  (a, b) => (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0),
                );

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['sender_id'] == user?.uid;
                    final isImage = message['messageType'] == 'image' || (message['imageUrl'] != null && message['imageUrl'].toString().isNotEmpty);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: isImage
                              ? const EdgeInsets.all(6)
                              : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? theme.colorScheme.primary
                                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: Radius.circular(isMe ? 20 : 4),
                              bottomRight: Radius.circular(isMe ? 4 : 20),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (isImage) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: message['imageUrl'],
                                    cacheManager: CustomCacheManager.instance,
                                    width: 220,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const SkeletonLoader(
                                      width: 220,
                                      height: 180,
                                      borderRadius: BorderRadius.all(Radius.circular(16)),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      width: 220,
                                      height: 180,
                                      color: theme.colorScheme.errorContainer,
                                      child: Icon(
                                        Icons.broken_image_rounded,
                                        color: theme.colorScheme.error,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ] else ...[
                                Text(
                                  message['text'] ?? '',
                                  style: TextStyle(
                                    color: isMe
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurface,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                              ],
                              Padding(
                                padding: isImage ? const EdgeInsets.only(right: 6, bottom: 4) : EdgeInsets.zero,
                                child: Text(
                                  _formatTime(message['timestamp']),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isMe
                                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          _ChatInput(
            onSendMessage: _sendMessage,
            onSendImage: _sendImage,
            t: t,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _ChatInput extends StatefulWidget {
  final Future<void> Function(String) onSendMessage;
  final Future<void> Function(File) onSendImage;
  final AppStrings t;

  const _ChatInput({
    required this.onSendMessage,
    required this.onSendImage,
    required this.t,
  });

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  late final TextEditingController _messageController;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  Future<void> _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      await widget.onSendMessage(text);
      _messageController.clear();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pickAndSendImage() async {
    final t = widget.t;

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: Text(t.camera),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded),
                title: Text(t.gallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() => _sending = true);

    try {
      final file = File(pickedFile.path);
      final compressedFile = await ImageUtils.compressAndGetWebp(file);
      if (compressedFile == null) {
        throw Exception();
      }

      await widget.onSendImage(compressedFile);
    } catch (e) {
      if (mounted) {
        AppNotifications.showError(context, t.sendError);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _sending ? null : _pickAndSendImage,
            icon: const Icon(Icons.add_a_photo_rounded),
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: widget.t.typeMessageHint,
                  hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filled(
            onPressed: _sending ? null : _handleSend,
            icon: _sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send_rounded),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

