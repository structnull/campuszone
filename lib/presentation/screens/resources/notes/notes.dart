import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:campuszone/presentation/screens/resources/comments/comments.dart';
import 'package:campuszone/presentation/screens/resources/notes/pdf.dart';
import 'package:campuszone/presentation/screens/resources/notes/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<NoteModel> _notes = [];
  final NoteRepository _repository = NoteRepository();
  final String? currentUserId = SupabaseService.currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }

  Future<void> _fetchNotes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final notes = await _repository.getAllNotes();
      if (mounted) {
        setState(() {
          _notes = notes;
          _isLoading = false;
        });
      }
    } catch (error) {
      AppLogger.error('Error fetching notes', error);
      if (mounted) {
        setState(() => _isLoading = false);
        AppDialog.showError(context: context, message: 'Failed to load notes');
      }
    }
  }

  Future<void> _deleteNote(NoteModel note) async {
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Confirm Delete',
      message: 'Are you sure you want to delete this note?',
      confirmText: 'Delete',
      isDanger: true,
    );
    if (!mounted) return;
    if (confirm != true) return;

    try {
      AppSnackbar.show(context, 'Deleting note...');
      await SupabaseService.notesBucket.remove([note.fileUrl]);
      await _repository.deleteNote(note.id);

      if (mounted) {
        AppSnackbar.show(context, 'Note deleted successfully');
        _fetchNotes();
      }
    } catch (e) {
      if (mounted) {
        AppDialog.showError(context: context, message: 'Failed to delete note');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(title: 'Notes', showBackButton: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadNotePage()),
          );
          if (result == true) _fetchNotes();
        },
        backgroundColor: AppColors.black,
        child: Icon(LineIcons.plus, color: AppColors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNotes,
        color: AppColors.primary,
        child: _isLoading
            ? ListView.builder(
                padding: EdgeInsets.all(AppSpacing.md),
                itemCount: 5,
                itemBuilder: (_, __) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.snackbar),
                  child: AppShimmerBox(
                    width: double.infinity,
                    height: 80,
                  ),
                ),
              )
            : _notes.isEmpty
                ? AppEmptyState(
                    icon: LineIcons.pdfFile, title: 'No notes found')
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.md, AppSpacing.md, 80),
                      itemCount: _notes.length,
                      itemBuilder: (context, index) {
                        final note = _notes[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: AppAnimations.slow,
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _NoteCard(
                                note: note,
                                isCurrentUser: note.userId == currentUserId,
                                onDelete: () => _deleteNote(note),
                                onOpen: () {
                                  final url = SupabaseService.notesBucket
                                      .getPublicUrl(note.fileUrl);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => PdfViewerPage(
                                              pdfUrl: Uri.parse(url),
                                              filePath: note.fileUrl,
                                              title: note.title,
                                            )),
                                  );
                                },
                                onComments: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => CommentsPage(
                                            entityId: note.id,
                                            entityType: 'notes'))),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isCurrentUser;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  final VoidCallback onComments;

  const _NoteCard({
    required this.note,
    required this.isCurrentUser,
    required this.onDelete,
    required this.onOpen,
    required this.onComments,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.snackbar),
                decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(30),
                    shape: BoxShape.circle),
                child: Icon(LineIcons.pdfFile,
                    color: AppColors.primary, size: AppIconSize.df),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(note.title, style: AppTextStyles.titleMedium),
                    Text(note.authorName ?? 'Unknown',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (isCurrentUser)
                IconButton(
                    icon: Icon(LineIcons.trash, color: AppColors.error),
                    onPressed: onDelete),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          if (note.description != null) ...[
            Text(note.description!, style: AppTextStyles.bodyMedium),
            SizedBox(height: AppSpacing.sm)
          ],
          Row(
            children: [
              if (note.subject != null) AppTag(label: note.subject!),
              if (note.semester != null) ...[
                SizedBox(width: AppSpacing.sm),
                AppTag(label: note.semester!)
              ],
              Spacer(),
              IconButton(icon: Icon(LineIcons.comment), onPressed: onComments),
            ],
          )
        ],
      ),
    );
  }
}
