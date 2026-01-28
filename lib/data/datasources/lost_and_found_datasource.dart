import 'dart:io';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:uuid/uuid.dart';

abstract class LostAndFoundDatasource {
  Future<void> createItem(String title, String description, File imageFile);
  Future<List<LostAndFoundModel>> getAllItems();
  Future<void> deleteItem(String id);
}

class SupabaseLostAndFoundDatasource implements LostAndFoundDatasource {
  @override
  Future<void> createItem(
      String title, String description, File imageFile) async {
    try {
      final user = SupabaseService.currentUserId;
      if (user == null) throw Exception("User not logged in");

      final String itemId = const Uuid().v4();
      final String filePath = '$user/$itemId.jpg';

      // Upload Image
      await SupabaseService.storage
          .from('lostandfound')
          .upload(filePath, imageFile);

      // Insert DB Record
      final model = LostAndFoundModel(
        id: itemId,
        userId: user,
        title: Sanitizer.text(title),
        description: Sanitizer.text(description),
        imagePath: filePath,
        createdAt: DateTime.now(),
      );

      await SupabaseService.client.from('lostandfound').insert(model.toJson());
    } catch (e) {
      AppLogger.error('Error creating lost and found item', e);
      rethrow;
    }
  }

  @override
  Future<List<LostAndFoundModel>> getAllItems() async {
    try {
      final response = await SupabaseService.client
          .from('lostandfound')
          .select('*, users(name)')
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => LostAndFoundModel.fromJson(e))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching lost and found items', e);
      return [];
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      final currentUserId = SupabaseService.currentUserId;
      if (currentUserId == null) throw Exception('Not authenticated');
      await SupabaseService.client
          .from('lostandfound')
          .delete()
          .eq('item_id', id)
          .eq('user_id', currentUserId);
    } catch (e) {
      AppLogger.error('Error deleting lost and found item', e);
      rethrow;
    }
  }
}
