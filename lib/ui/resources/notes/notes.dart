import 'package:campuszone/globals.dart';
import 'package:campuszone/ui/resources/comments/comments.dart';
import 'package:campuszone/ui/resources/notes/upload_data.dart';
import 'package:campuszone/ui/resources/notes/pdf.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:pdfrx/pdfrx.dart'; // Updated import

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  double _loadingProgress = 0.0;
  List<dynamic> _notes = [];
  late AnimationController _animationController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fetchNotes();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchNotes() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0;
    });

    try {
      final progressTimer =
          Stream.periodic(const Duration(milliseconds: 100), (i) => i)
              .take(10)
              .listen((i) {
        if (mounted) {
          setState(() {
            _loadingProgress = (i + 1) / 10;
          });
        }
      });

      final data = await Supabase.instance.client.from('notes').select('''
        *,
        user:users ( id, name, email )
      ''').order('created_at', ascending: false);

      await progressTimer.cancel();

      if (mounted) {
        setState(() {
          _notes = data as List<dynamic>;
          _isLoading = false;
          _loadingProgress = 1.0;
        });
        _animationController.forward(from: 0.0);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProgress = 0.0;
        });
        _showErrorDialog('Failed to load notes. Please try again.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(LineIcons.exclamationCircle, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Error', style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
        elevation: 10,
      ),
    );
  }

  Future<void> _confirmDelete(dynamic note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(LineIcons.trash, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
        elevation: 10,
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        _showLoadingSnackBar('Deleting note...');
        final String? filePath = note['file_path'] as String?;
        if (filePath != null && filePath.isNotEmpty) {
          await Supabase.instance.client.storage
              .from('notes')
              .remove([filePath]);
        }
        await Supabase.instance.client
            .from('notes')
            .delete()
            .eq('note_id', note['note_id']);

        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(LineIcons.check, color: Colors.white),
                SizedBox(width: 8),
                Text('Note deleted successfully.'),
              ],
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );

        _fetchNotes();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showErrorDialog('Error deleting note. Please try again.');
        }
      }
    }
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openCommentsPage(String noteId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          entityId: noteId,
          entityType: 'notes',
        ),
      ),
    );
  }

  void _openPdf(String filePath, Map<String, dynamic> note) async {
    final url =
        Supabase.instance.client.storage.from('notes').getPublicUrl(filePath);
    final pdfUrl = Uri.parse(url);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerPage(
          title: note['title'] ?? 'Untitled',
          filePath: filePath,
          pdfUrl: pdfUrl,
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildProfilePic(String userId) {
    final baseUrl = Supabase.instance.client.storage
        .from('profilepic')
        .getPublicUrl('$userId/profile_picture.jpg');
    final String profileUrl = (globalCacheBuster.value ?? '').isNotEmpty
        ? '$baseUrl?cacheBuster=$globalCacheBuster'
        : baseUrl;

    return Hero(
      tag: 'profile1-$userId$globalCacheBuster',
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withAlpha(50),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            profileUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Excalifont',
            fontSize: 32,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const UploadDataPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final tween =
                      Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOutCubic));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            ).then((result) {
              if (result == true) {
                _refreshIndicatorKey.currentState?.show();
              }
            });
          },
          backgroundColor: Colors.black,
          elevation: 6,
          child: const Icon(LineIcons.plus, color: Colors.white, size: 28),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _fetchNotes,
            color: Colors.black,
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: 5,
                    itemBuilder: (context, index) => _buildLoadingCard(),
                  )
                : _notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LineIcons.search,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No notes found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to upload a note!',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          final Map<String, dynamic>? user =
                              note['user'] as Map<String, dynamic>?;
                          final String userName =
                              user?['name'] ?? 'Unknown User';

                          final String? filePath = note['file_path'] as String?;
                          String? pdfUrl;
                          if (filePath != null && filePath.isNotEmpty) {
                            pdfUrl = Supabase.instance.client.storage
                                .from('notes')
                                .getPublicUrl(filePath);
                            if ((globalCacheBuster.value ?? '').isNotEmpty) {
                              pdfUrl = '$pdfUrl?t=$globalCacheBuster';
                            }
                          }

                          return Card(
                            elevation: 4,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.grey.shade200, width: 1),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      (user != null && user['id'] != null)
                                          ? _buildProfilePic(user['id'])
                                          : Container(
                                              width: 48,
                                              height: 48,
                                              color: Colors.grey,
                                            ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _formatDate(note['created_at']),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (pdfUrl != null && pdfUrl.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => _openPdf(filePath!, note),
                                    child: Hero(
                                      tag: 'pdf_${note['note_id']}',
                                      child: Container(
                                        height: 250,
                                        color: Colors.black,
                                        child: FutureBuilder<PdfDocument>(
                                          future: PdfDocument.openUri(
                                              Uri.parse(pdfUrl)),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            } else if (snapshot.hasError) {
                                              return Center(
                                                  child: Text(
                                                      'Error loading PDF: ${snapshot.error}'));
                                            } else if (!snapshot.hasData) {
                                              return const Center(
                                                  child: Text('No PDF found.'));
                                            }

                                            final document = snapshot.data!;
                                            return PdfPageView(
                                              document: document,
                                              pageNumber: 1,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note['title'] ?? 'No Title',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        note['description'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const Divider(height: 24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildActionButton(
                                            icon: LineIcons.comment,
                                            label: 'Comments',
                                            onTap: () => _openCommentsPage(
                                                note['note_id'].toString()),
                                          ),
                                          if (currentUserId != null &&
                                              note['user_id'] == currentUserId)
                                            _buildActionButton(
                                              icon: LineIcons.trash,
                                              label: 'Delete',
                                              color: Colors.red,
                                              onTap: () => _confirmDelete(note),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress,
                backgroundColor: Colors.grey[300],
                color: Colors.black,
                minHeight: 4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
