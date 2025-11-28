import 'package:campuszone/ui/resources/comments/commentitem.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsPage extends StatefulWidget {
  final String entityId; // ID of the entity (e.g., noteId, lostAndFoundId)
  final String entityType; // Type of the entity (e.g., "notes", "lostandfound")

  const CommentsPage({
    super.key,
    required this.entityId,
    required this.entityType,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  bool _isLoading = false;
  bool _isPosting = false;
  List<Map<String, dynamic>> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _commentController.addListener(() => setState(() {}));
  }

  String _getTableName() {
    // Map entityType to the correct table name
    if (widget.entityType == 'notes') {
      return 'ncomments';
    } else if (widget.entityType == 'lostandfound') {
      return 'lafcomments';
    } else {
      throw Exception('Invalid entityType: ${widget.entityType}');
    }
  }

  Future<void> _fetchComments() async {
    setState(() => _isLoading = true);
    try {
      final tableName = _getTableName();
      debugPrint('Fetching comments from table: $tableName');
      debugPrint('Entity Type: ${widget.entityType}');
      debugPrint('Entity ID: ${widget.entityId}');

      final response = await Supabase.instance.client
          .from(tableName)
          .select('*')
          .eq('item_id', widget.entityId);

      debugPrint('Supabase response: $response');

      final data = List<Map<String, dynamic>>.from(response);
      if (mounted) {
        setState(() => _comments = data);
      }
    } catch (error) {
      debugPrint('Error fetching comments: ${error.toString()}');
      debugPrintStack(stackTrace: StackTrace.current); // Print stack trace
      if (mounted) {
        _showErrorDialog('Failed to load comments. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      final tableName = _getTableName();
      await Supabase.instance.client
          .from(tableName)
          .delete()
          .eq('id', commentId);
      setState(() {
        _comments.removeWhere((comment) => comment['id'] == commentId);
      });
    } catch (error) {
      debugPrint('Error deleting comment: ${error.toString()}');
      _showErrorDialog('Failed to delete comment. Please try again.');
    }
  }

  Future<void> _postComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;
    setState(() => _isPosting = true);
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        _showErrorDialog('You must be logged in to post a comment.');
        setState(() => _isPosting = false);
        return;
      }

      final tableName = _getTableName();
      await Supabase.instance.client.from(tableName).insert({
        'user_id': currentUser.id,
        'item_id': widget
            .entityId, // Use `item_id` instead of `${widget.entityType}_id`
        'comment_text': commentText,
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      _commentController.clear();
      await _fetchComments();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (error) {
      debugPrint('Error posting comment: ${error.toString()}');
      _showErrorDialog('Error posting comment. Please try again.');
    }
    if (mounted) {
      setState(() => _isPosting = false);
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.redAccent)),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments', style: TextStyle(fontSize: 24)),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildCommentShimmer()
                : RefreshIndicator(
                    onRefresh: _fetchComments,
                    color: Colors.black,
                    child: _comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LineIcons.comment,
                                    size: 48, color: Colors.black26),
                                const SizedBox(height: 16),
                                const Text(
                                  'No comments yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to comment!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return CommentItem(
                                comment: comment,
                                currentUserId: currentUserId,
                                formattedDate:
                                    _formatDate(comment['created_at']),
                                onDelete: () => _deleteComment(comment['id']),
                              );
                            },
                          ),
                  ),
          ),
          const Divider(height: 1),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            offset: const Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isPosting
                ? Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(6),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Material(
                    color: _commentController.text.trim().isEmpty
                        ? Colors.grey[300]
                        : Colors.black,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: _commentController.text.trim().isEmpty
                          ? null
                          : _postComment,
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: Icon(
                          LineIcons.paperPlane,
                          color: _commentController.text.trim().isEmpty
                              ? Colors.grey[500]
                              : Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return timeago.format(date);
    } catch (e) {
      return '';
    }
  }

  Widget _buildCommentShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}
