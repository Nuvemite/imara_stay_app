import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/messages/models/conversation_model.dart';

class ConversationsRepository {
  ConversationsRepository(this._getToken);

  final Future<String?> Function() _getToken;

  Future<List<ConversationItem>> fetchConversations() async {
    if (!ApiConfig.useApi) return [];

    final token = await _getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse(ApiConfig.url('/conversations')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 200) return [];

    try {
      final list = jsonDecode(response.body) as List;
      return list
          .map((e) => ConversationItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<ConversationDetail?> fetchConversation(int id) async {
    if (!ApiConfig.useApi) return null;

    final token = await _getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(ApiConfig.url('/conversations/$id')),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 200) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ConversationDetail.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<MessageItem?> sendMessage(int conversationId, String content) async {
    final token = await _getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse(ApiConfig.url('/conversations/$conversationId/messages')),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));

    if (response.statusCode != 201) return null;

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return MessageItem.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}

final conversationsRepositoryProvider = Provider<ConversationsRepository>((ref) {
  return ConversationsRepository(() => AuthController.getStoredToken());
});
