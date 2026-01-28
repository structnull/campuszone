import 'dart:io';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:uuid/uuid.dart';

abstract class NoteDatasource {
  Future<List<NoteModel>> getAllNotes();
  Future<void> uploadNote({
    required String title,
    required String description,
    required File file,
    String? subject,
    String? semester,
  });
  Future<void> deleteNote(String id);
  Stream<List<NoteModel>> watchNotes();
}

class SupabaseNoteDatasource implements NoteDatasource {
  @override
  Future<List<NoteModel>> getAllNotes() async {
    try {
      final response = await SupabaseService.notesTable
          .select('*, user:users(id, name, email)')
          .order('created_at', ascending: false);
      return (response as List)
          .map((json) => NoteModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching notes', e);
      return [];
    }
  }

  @override
  Future<void> uploadNote({
    required String title,
    required String description,
    required File file,
    String? subject,
    String? semester,
  }) async {
    try {
      final user = SupabaseService.currentUserId;
      if (user == null) throw Exception("User not logged in");

      final String noteId = const Uuid().v4();
      final String filePath = '$user/$noteId.pdf';

      // Upload PDF
      await SupabaseService.storage.from('notes').upload(filePath, file);

      // Insert Record
      final note = NoteModel(
        id: noteId,
        userId: user,
        title: Sanitizer.text(title),
        description: Sanitizer.text(description),
        fileUrl: filePath,
        subject: subject != null ? Sanitizer.text(subject) : null,
        semester: semester,
        createdAt: DateTime.now(),
      );

      await SupabaseService.notesTable.insert(note.toJson());
    } catch (e) {
      AppLogger.error('Error uploading note', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      final currentUserId = SupabaseService.currentUserId;
      if (currentUserId == null) throw Exception('Not authenticated');
      await SupabaseService.notesTable
          .delete()
          .eq('id', id)
          .eq('user_id', currentUserId);
    } catch (e) {
      AppLogger.error('Error deleting note', e);
      rethrow;
    }
  }

  @override
  Stream<List<NoteModel>> watchNotes() {
    return SupabaseService.notesTable
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => NoteModel.fromJson(json)).toList());
  }
}
