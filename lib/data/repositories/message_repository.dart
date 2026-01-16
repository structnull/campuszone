import 'package:campuszone/data/datasources/message_datasource.dart';
import 'package:campuszone/data/models/message_model.dart';

class MessageRepository {
  final MessageDatasource _datasource;

  MessageRepository({MessageDatasource? datasource})
      : _datasource = datasource ?? SupabaseMessageDatasource();

  Future<List<MessageModel>> getMessages(
      String currentUserId, String otherUserId) {
    return _datasource.getMessages(currentUserId, otherUserId);
  }

  Future<MessageModel> sendMessage({
    required String text,
    required String senderId,
    required String receiverId,
  }) {
    return _datasource.sendMessage(text, senderId, receiverId);
  }

  Future<void> deleteMessage(String messageId) {
    return _datasource.deleteMessage(messageId);
  }

  Stream<List<MessageModel>> getMessagesStream(
      String currentUserId, String otherUserId) {
    return _datasource.getMessagesStream(currentUserId, otherUserId);
  }
}
