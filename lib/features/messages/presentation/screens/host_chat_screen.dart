import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/messages/models/conversation_model.dart';
import 'package:imara_stay/features/messages/repository/conversations_repository.dart';

/// Host chat - GET /api/conversations/{id}, POST /api/conversations/{id}/messages
class HostChatScreen extends ConsumerStatefulWidget {
  const HostChatScreen({
    super.key,
    required this.conversationId,
    required this.otherUserName,
  });

  final int conversationId;
  final String otherUserName;

  @override
  ConsumerState<HostChatScreen> createState() => _HostChatScreenState();
}

class _HostChatScreenState extends ConsumerState<HostChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  ConversationDetail? _conversation;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final repo = ref.read(conversationsRepositoryProvider);
    final conv = await repo.fetchConversation(widget.conversationId);
    if (mounted) {
      setState(() {
        _conversation = conv;
        _loading = false;
      });
      if (conv != null && conv.messages.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      }
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    _controller.clear();
    setState(() => _sending = true);

    final repo = ref.read(conversationsRepositoryProvider);
    final msg = await repo.sendMessage(widget.conversationId, text);

    if (mounted) {
      setState(() {
        _sending = false;
        if (msg != null && _conversation != null) {
          _conversation = ConversationDetail(
            id: _conversation!.id,
            otherUser: _conversation!.otherUser,
            listing: _conversation!.listing,
            messages: [..._conversation!.messages, msg],
          );
        }
      });
      if (msg != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
        backgroundColor: AppTheme.white,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            )
          : Column(
              children: [
                Expanded(
                  child: _conversation == null || _conversation!.messages.isEmpty
                      ? Center(
                          child: Text(
                            'No messages yet. Send one to start the conversation.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.greyText),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: _conversation!.messages.length,
                          itemBuilder: (context, i) {
                            final m = _conversation!.messages[i];
                            final userId = ref.read(authProvider).user?.id;
                            final isMe = userId != null &&
                                m.senderId.toString() == userId;
                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe
                                      ? AppTheme.primaryRed
                                      : AppTheme.lightGrey,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  m.content,
                                  style: TextStyle(
                                    color: isMe ? Colors.white : AppTheme.darkText,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  color: AppTheme.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppTheme.lightGrey,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      IconButton.filled(
                        onPressed: _sending ? null : _send,
                        icon: _sending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
