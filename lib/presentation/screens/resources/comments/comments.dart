import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/comment_repository.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:campuszone/presentation/screens/resources/comments/commentitem.dart';
import 'package:flutter/material.dart';

class CommentsPage extends StatefulWidget {
  final String entityId;
  final String entityType; // "notes" or "lostandfound"

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
  List<CommentModel> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CommentRepository _repository = CommentRepository();
  final String? currentUserId = SupabaseService.currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchComments();
    _commentController.addListener(() => setState(() {}));
  }

  Future<void> _fetchComments() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final comments =
          await _repository.getComments(widget.entityType, widget.entityId);
      if (mounted) {
        setState(() {
          _comments = comments;
        });
      }
    } catch (error) {
      if (mounted) {
        AppSnackbar.show(context, 'Failed to load comments', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(widget.entityType, commentId);
      if (mounted) {
        setState(() {
          _comments.removeWhere((comment) => comment.id == commentId);
        });
        AppSnackbar.show(context, 'Comment deleted');
      }
    } catch (error) {
      if (mounted) {
        AppSnackbar.show(context, 'Failed to delete comment', isError: true);
      }
    }
  }

  Future<void> _postComment() async {
    final commentText = _commentController.text.trim();
    if (commentText.isEmpty) return;

    if (currentUserId == null) {
      AppDialog.showError(
          context: context,
          message: 'You must be logged in to post a comment.');
      return;
    }

    setState(() => _isPosting = true);
    try {
      await _repository.postComment(
          widget.entityType, widget.entityId, commentText);

      _commentController.clear();
      await _fetchComments();
      if (mounted && _scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (error) {
      if (mounted) {
        AppSnackbar.show(context, 'Error posting comment', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(title: 'Comments', showBackButton: true),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildCommentShimmer()
                : RefreshIndicator(
                    onRefresh: _fetchComments,
                    color: AppColors.primary,
                    child: _comments.isEmpty
                        ? SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.7,
                              alignment: Alignment.center,
                              child: AppEmptyState(
                                icon: Icons.chat_bubble_outline,
                                title: 'No comments yet',
                                subtitle: 'Be the first to comment!',
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(AppSpacing.md),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return CommentItem(
                                comment: comment,
                                currentUserId: currentUserId,
                                onDelete: () => _deleteComment(comment.id),
                              );
                            },
                          ),
                  ),
          ),
          Divider(height: 1, color: AppColors.borderLight),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            offset: Offset(0, -1),
            blurRadius: 3,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _commentController,
                hintText: 'Add a comment...',
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            _isPosting
                ? Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary)),
                  )
                : IconButton(
                    icon: Icon(Icons.send),
                    color: AppColors.primary,
                    disabledColor: AppColors.textSecondary,
                    onPressed: _commentController.text.trim().isEmpty
                        ? null
                        : _postComment,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentShimmer() {
    return ListView.builder(
      itemCount: 5,
      padding: EdgeInsets.all(AppSpacing.md),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: AppShimmerBox(
            width: double.infinity,
            height: 80,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}
