import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/message_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class MessageDatasource {
  Future<List<MessageModel>> getMessages(
      String currentUserId, String otherUserId);
  Future<MessageModel> sendMessage(
      String text, String senderId, String receiverId);
  Future<void> deleteMessage(String messageId);
  Stream<List<MessageModel>> getMessagesStream(
      String currentUserId, String otherUserId);
}

class SupabaseMessageDatasource implements MessageDatasource {
  final SupabaseClient _client = SupabaseService.client;

  @override
  Future<List<MessageModel>> getMessages(
      String currentUserId, String otherUserId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .or('and(send_id.eq.$currentUserId,recipient_id.eq.$otherUserId),and(send_id.eq.$otherUserId,recipient_id.eq.$currentUserId)')
          .order('created_at', ascending: true)
          .limit(100);

      return (response as List).map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      AppLogger.error('Error fetching messages: $e', e);
      throw Exception('Failed to fetch messages');
    }
  }

  @override
  Future<MessageModel> sendMessage(
      String text, String senderId, String receiverId) async {
    try {
      final data = {
        'content': Sanitizer.text(text),
        'send_id': senderId,
        'recipient_id': receiverId,
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      final response =
          await _client.from('messages').insert(data).select().single();
      return MessageModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error sending message: $e', e);
      throw Exception('Failed to send message');
    }
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    try {
      final currentUserId = SupabaseService.currentUserId;
      if (currentUserId == null) throw Exception('Not authenticated');
      await _client
          .from('messages')
          .delete()
          .eq('id', messageId)
          .eq('send_id', currentUserId);
    } catch (e) {
      AppLogger.error('Error deleting message: $e', e);
      throw Exception('Failed to delete message');
    }
  }

  // Basic stream implementation using Supabase Realtime
  // Note: This needs careful handling of "new" vs "all" messages.
  // For simplicity, we expose a stream of "updates" or rely on the UI to managing the list via events.
  // Here we just return a stream of events for the table involving these users.
  @override
  Stream<List<MessageModel>> getMessagesStream(
      String currentUserId, String otherUserId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((maps) => maps.map((e) => MessageModel.fromJson(e)).where((msg) {
              return (msg.senderId == currentUserId &&
                      msg.receiverId == otherUserId) ||
                  (msg.senderId == otherUserId &&
                      msg.receiverId == currentUserId);
            }).toList());
  }
}
