/// Conversation from GET /api/conversations
class ConversationItem {
  const ConversationItem({
    required this.id,
    required this.otherUser,
    this.listing,
    this.lastMessage,
    required this.unreadCount,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final ConversationUser otherUser;
  final ConversationListing? listing;
  final ConversationLastMessage? lastMessage;
  final int unreadCount;
  final String createdAt;
  final String updatedAt;

  factory ConversationItem.fromJson(Map<String, dynamic> json) {
    final otherRaw = json['other_user'] as Map<String, dynamic>? ?? {};
    final listingRaw = json['listing'] as Map<String, dynamic>?;
    final lastRaw = json['last_message'] as Map<String, dynamic>?;

    return ConversationItem(
      id: (json['id'] ?? 0) as int,
      otherUser: ConversationUser.fromJson(otherRaw),
      listing: listingRaw != null ? ConversationListing.fromJson(listingRaw) : null,
      lastMessage: lastRaw != null ? ConversationLastMessage.fromJson(lastRaw) : null,
      unreadCount: (json['unread_count'] ?? 0) as int,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class ConversationUser {
  const ConversationUser({
    required this.id,
    required this.name,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String? avatarUrl;

  factory ConversationUser.fromJson(Map<String, dynamic> json) {
    return ConversationUser(
      id: (json['id'] ?? 0) as int,
      name: json['name']?.toString() ?? 'User',
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}

class ConversationListing {
  const ConversationListing({
    required this.id,
    required this.title,
    this.imageUrl,
  });

  final int id;
  final String title;
  final String? imageUrl;

  factory ConversationListing.fromJson(Map<String, dynamic> json) {
    return ConversationListing(
      id: (json['id'] ?? 0) as int,
      title: json['title']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
    );
  }
}

class ConversationLastMessage {
  const ConversationLastMessage({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.readAt,
  });

  final int id;
  final String content;
  final int senderId;
  final String createdAt;
  final String? readAt;

  factory ConversationLastMessage.fromJson(Map<String, dynamic> json) {
    return ConversationLastMessage(
      id: (json['id'] ?? 0) as int,
      content: json['content']?.toString() ?? '',
      senderId: (json['sender_id'] ?? 0) as int,
      createdAt: json['created_at']?.toString() ?? '',
      readAt: json['read_at']?.toString(),
    );
  }
}

/// Full conversation with messages from GET /api/conversations/{id}
class ConversationDetail {
  const ConversationDetail({
    required this.id,
    required this.otherUser,
    this.listing,
    required this.messages,
  });

  final int id;
  final ConversationUser otherUser;
  final ConversationListing? listing;
  final List<MessageItem> messages;

  factory ConversationDetail.fromJson(Map<String, dynamic> json) {
    final messagesRaw = json['messages'] as List? ?? [];
    return ConversationDetail(
      id: (json['id'] ?? 0) as int,
      otherUser: ConversationUser.fromJson(
        Map<String, dynamic>.from(json['other_user'] as Map? ?? {}),
      ),
      listing: json['listing'] != null
          ? ConversationListing.fromJson(
              Map<String, dynamic>.from(json['listing'] as Map),
            )
          : null,
      messages: messagesRaw
          .map((e) => MessageItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class MessageItem {
  const MessageItem({
    required this.id,
    required this.content,
    required this.senderId,
    required this.createdAt,
    this.readAt,
  });

  final int id;
  final String content;
  final int senderId;
  final String createdAt;
  final String? readAt;

  factory MessageItem.fromJson(Map<String, dynamic> json) {
    return MessageItem(
      id: (json['id'] ?? 0) as int,
      content: json['content']?.toString() ?? '',
      senderId: (json['sender_id'] ?? 0) as int,
      createdAt: json['created_at']?.toString() ?? '',
      readAt: json['read_at']?.toString(),
    );
  }
}
