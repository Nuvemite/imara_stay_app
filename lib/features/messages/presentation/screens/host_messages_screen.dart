import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/core/widgets/imara_stay_logo.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/messages/models/conversation_model.dart';
import 'package:imara_stay/features/messages/presentation/screens/host_chat_screen.dart';
import 'package:imara_stay/features/messages/repository/conversations_repository.dart';

/// Host messages inbox - GET /api/conversations
class HostMessagesScreen extends ConsumerStatefulWidget {
  const HostMessagesScreen({super.key});

  @override
  ConsumerState<HostMessagesScreen> createState() => _HostMessagesScreenState();
}

class _HostMessagesScreenState extends ConsumerState<HostMessagesScreen> {
  List<ConversationItem> _conversations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(conversationsRepositoryProvider);
    final list = await repo.fetchConversations();
    if (mounted) {
      setState(() {
        _conversations = list;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        title: const ImaraStayLogo(
          size: ImaraStayLogoSize.small,
          showIcon: false,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.greyText),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryRed),
            )
          : _conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: AppTheme.greyText.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'No messages',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Messages from guests will appear here.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.greyText,
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppTheme.primaryRed,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: _conversations.length,
                    itemBuilder: (context, i) {
                      final c = _conversations[i];
                      return _ConversationTile(
                        conversation: c,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => HostChatScreen(
                                conversationId: c.id,
                                otherUserName: c.otherUser.name,
                              ),
                            ),
                          ).then((_) => _load());
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
  });

  final ConversationItem conversation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryRed.withValues(alpha: 0.2),
          child: Text(
            conversation.otherUser.name.isNotEmpty
                ? conversation.otherUser.name[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.otherUser.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (conversation.unreadCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (conversation.listing != null)
              Text(
                conversation.listing!.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.greyText,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (conversation.lastMessage != null)
              Text(
                conversation.lastMessage!.content,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.greyText,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
