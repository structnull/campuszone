import 'package:campuszone/data/datasources/datasources.dart';
import 'package:campuszone/data/models/models.dart';

class PostRepository {
  final PostDatasource _datasource;

  PostRepository({PostDatasource? datasource})
      : _datasource = datasource ?? SupabasePostDatasource();

  Future<List<PostModel>> getAllPosts() => _datasource.getAllPosts();
  Future<PostModel?> getPostById(String id) => _datasource.getPostById(id);
  Future<void> createPost(PostModel post) => _datasource.createPost(post);
  Future<void> deletePost(String id) => _datasource.deletePost(id);
  Stream<List<PostModel>> watchPosts() => _datasource.watchPosts();
}
