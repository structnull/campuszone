import 'dart:io';
import 'package:campuszone/data/datasources/datasources.dart';
import 'package:campuszone/data/models/models.dart';

class NoteRepository {
  final NoteDatasource _datasource;

  NoteRepository({NoteDatasource? datasource})
      : _datasource = datasource ?? SupabaseNoteDatasource();

  Future<List<NoteModel>> getAllNotes() {
    return _datasource.getAllNotes();
  }

  Future<void> uploadNote({
    required String title,
    required String description,
    required File file,
    String? subject,
    String? semester,
  }) {
    return _datasource.uploadNote(
      title: title,
      description: description,
      file: file,
      subject: subject,
      semester: semester,
    );
  }

  Future<void> deleteNote(String id) {
    return _datasource.deleteNote(id);
  }

  Stream<List<NoteModel>> watchNotes() {
    return _datasource.watchNotes();
  }
}
