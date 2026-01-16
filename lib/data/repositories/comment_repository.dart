import 'package:campuszone/data/datasources/comment_datasource.dart';
import 'package:campuszone/data/models/models.dart';

class CommentRepository {
  final CommentDatasource _datasource;

  CommentRepository({CommentDatasource? datasource})
      : _datasource = datasource ?? SupabaseCommentDatasource();

  Future<List<CommentModel>> getComments(String entityType, String entityId) {
    return _datasource.getComments(entityType, entityId);
  }

  Future<void> postComment(String entityType, String entityId, String text) {
    return _datasource.postComment(entityType, entityId, text);
  }

  Future<void> deleteComment(String entityType, String commentId) {
    return _datasource.deleteComment(entityType, commentId);
  }
}
