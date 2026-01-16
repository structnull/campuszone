import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';

abstract class PostDatasource {
  Future<List<PostModel>> getAllPosts();
  Future<PostModel?> getPostById(String id);
  Future<void> createPost(PostModel post);
  Future<void> deletePost(String id);
  Stream<List<PostModel>> watchPosts();
}

class SupabasePostDatasource implements PostDatasource {
  @override
  Future<List<PostModel>> getAllPosts() async {
    try {
      final response = await SupabaseService.client
          .from('lostandfound')
          .select('*, user:users(id, name, email)')
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => PostModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching posts', e);
      return [];
    }
  }

  @override
  Future<PostModel?> getPostById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('lostandfound')
          .select('*, user:users(id, name, email)')
          .eq('item_id', id) // Using item_id as per legacy schema
          .maybeSingle();
      return response != null ? PostModel.fromJson(response) : null;
    } catch (e) {
      AppLogger.error('Error fetching post by id', e);
      return null;
    }
  }

  @override
  Future<void> createPost(PostModel post) async {
    try {
      await SupabaseService.client.from('lostandfound').insert(post.toJson());
    } catch (e) {
      AppLogger.error('Error creating post', e);
      rethrow;
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      // If id is numeric/uuid mismatch, handle carefully.
      // Legacy uses item_id.
      await SupabaseService.client
          .from('lostandfound')
          .delete()
          .eq('item_id', id);
    } catch (e) {
      AppLogger.error('Error deleting post', e);
      rethrow;
    }
  }

  @override
  Stream<List<PostModel>> watchPosts() {
    return SupabaseService.client
        .from('lostandfound')
        .stream(primaryKey: ['item_id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => PostModel.fromJson(json)).toList());
  }
}
