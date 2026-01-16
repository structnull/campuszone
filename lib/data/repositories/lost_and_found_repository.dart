import 'dart:io';
import 'package:campuszone/data/datasources/datasources.dart';
import 'package:campuszone/data/models/models.dart';

class LostAndFoundRepository {
  final LostAndFoundDatasource _datasource;

  LostAndFoundRepository({LostAndFoundDatasource? datasource})
      : _datasource = datasource ?? SupabaseLostAndFoundDatasource();

  Future<void> createItem({
    required String title,
    required String description,
    required File imageFile,
  }) {
    return _datasource.createItem(title, description, imageFile);
  }

  Future<List<LostAndFoundModel>> getAllItems() {
    return _datasource.getAllItems();
  }

  Future<void> deleteItem(String id) {
    return _datasource.deleteItem(id);
  }
}
