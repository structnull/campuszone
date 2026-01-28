import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/presentation/widgets/common/common.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A chat message bubble widget with sender avatar and timestamp.
///
/// Used in the Chat page to display individual messages with
/// different styling for sent vs received messages.
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMyMessage;
  final String? senderProfileUrl;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMyMessage,
    this.senderProfileUrl,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          mainAxisAlignment:
              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMyMessage) ...[
              AppAvatar(imageUrl: senderProfileUrl, radius: AppSpacing.lg),
              SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                    color:
                        isMyMessage ? AppColors.primary : AppColors.cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                      bottomLeft: isMyMessage
                          ? Radius.circular(AppRadius.lg)
                          : Radius.circular(AppRadius.tiny),
                      bottomRight: isMyMessage
                          ? Radius.circular(AppRadius.tiny)
                          : Radius.circular(AppRadius.lg),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.05),
                          blurRadius: AppElevation.low,
                          offset: Offset(0, 1))
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: isMyMessage
                              ? AppColors.white
                              : AppColors.textPrimary),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      timeago.format(message.createdAt),
                      style: AppTextStyles.caption.copyWith(
                          color: isMyMessage
                              ? AppColors.white.withValues(alpha: 0.7)
                              : AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
