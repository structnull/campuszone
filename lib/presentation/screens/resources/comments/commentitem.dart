import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatefulWidget {
  final CommentModel comment;
  final String? currentUserId;
  final Future<void> Function() onDelete;

  const CommentItem({
    super.key,
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
  });

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem>
    with SingleTickerProviderStateMixin {
  bool _showOverlay = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    if (mounted) {
      setState(() {
        _showOverlay = !_showOverlay;
        if (_showOverlay) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }
      });
    }
  }

  Future<void> _showDeleteConfirmation() async {
    _toggleOverlay();

    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Delete Comment',
      message:
          'Are you sure you want to delete this comment? This action cannot be undone.',
      confirmText: 'DELETE',
      isDanger: true,
    );

    if (confirm == true) {
      await widget.onDelete();
    }
  }

  bool get _isOwnComment =>
      widget.currentUserId != null &&
      widget.currentUserId == widget.comment.userId;

  @override
  Widget build(BuildContext context) {
    final displayName = widget.comment.authorName ?? 'Anonymous';
    final formattedDate = timeago.format(widget.comment.createdAt);

    return GestureDetector(
      onLongPress: _isOwnComment ? _toggleOverlay : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              AppCard(
                padding: EdgeInsets.all(AppSpacing.md),
                elevation: 2, // Low elevation for comments
                borderRadius: BorderRadius.circular(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppAvatar(
                      name: displayName,
                      radius: 20,
                      fontSize: 18,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                displayName,
                                style: AppTextStyles.titleSmall,
                              ),
                              Text(
                                formattedDate,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            widget.comment.commentText,
                            style: AppTextStyles.bodyMedium,
                          ),
                          if (_isOwnComment)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'Tap and hold to manage',
                                  style: AppTextStyles.caption.copyWith(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_showOverlay)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _toggleOverlay,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppButton(
                              text: 'Delete',
                              icon: Icons.delete,
                              backgroundColor: AppColors.error,
                              onPressed: _showDeleteConfirmation,
                              height: 40,
                              width: 120,
                            ),
                            SizedBox(width: AppSpacing.md),
                            AppButton(
                              text: 'Cancel',
                              icon: Icons.close,
                              backgroundColor: AppColors.textSecondary,
                              onPressed: _toggleOverlay,
                              height: 40,
                              width: 120,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
