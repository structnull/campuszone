import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';

abstract class CommentDatasource {
  Future<List<CommentModel>> getComments(String entityType, String entityId);
  Future<void> postComment(String entityType, String entityId, String text);
  Future<void> deleteComment(String entityType, String commentId);
}

class SupabaseCommentDatasource implements CommentDatasource {
  String _getTableName(String entityType) {
    if (entityType == 'notes') return 'ncomments';
    if (entityType == 'lostandfound') return 'lafcomments';
    throw Exception('Unknown entity type: $entityType');
  }

  @override
  Future<List<CommentModel>> getComments(
      String entityType, String entityId) async {
    try {
      final tableName = _getTableName(entityType);
      final response = await SupabaseService.client
          .from(tableName)
          .select('*, users(name)')
          .eq('item_id', entityId)
          .order('created_at', ascending: true);

      return (response as List).map((e) => CommentModel.fromJson(e)).toList();
    } catch (e) {
      AppLogger.error('Error fetching comments', e);
      return [];
    }
  }

  @override
  Future<void> postComment(
      String entityType, String entityId, String text) async {
    try {
      final user = SupabaseService.currentUserId;
      if (user == null) throw Exception("User not logged in");

      final tableName = _getTableName(entityType);
      await SupabaseService.client.from(tableName).insert({
        'user_id': user,
        'item_id': entityId,
        'comment_text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      AppLogger.error('Error posting comment', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteComment(String entityType, String commentId) async {
    try {
      final tableName = _getTableName(entityType);
      await SupabaseService.client.from(tableName).delete().eq('id', commentId);
    } catch (e) {
      AppLogger.error('Error deleting comment', e);
      rethrow;
    }
  }
}
