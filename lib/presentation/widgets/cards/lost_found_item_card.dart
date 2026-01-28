import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/globals.dart' as globals;
import 'package:campuszone/presentation/widgets/common/common.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A card widget displaying lost & found item information.
///
/// Used in the Lost & Found page to display individual items
/// with image, author info, and action buttons.
class LostFoundItemCard extends StatelessWidget {
  final LostAndFoundModel item;
  final bool isCurrentUser;
  final VoidCallback onDelete;
  final VoidCallback onComments;

  const LostFoundItemCard({
    super.key,
    required this.item,
    required this.isCurrentUser,
    required this.onDelete,
    required this.onComments,
  });

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (item.imagePath.isNotEmpty) {
      imageUrl = SupabaseService.storage
          .from('lostandfound')
          .getPublicUrl(item.imagePath);
    }

    final profileUrl = SupabaseService.getProfilePictureUrl(item.userId,
        cacheBuster: globals.globalCacheBuster.value);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                AppAvatar(imageUrl: profileUrl, radius: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.authorName ?? 'Unknown User',
                          style: AppTextStyles.bodyLargeBold),
                      Text(timeago.format(item.createdAt),
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
          ),
          if (imageUrl != null)
            AppNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              enablePreview: true,
              height: 300,
            ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.headlineSmall),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: AppSpacing.xs),
                  Text(item.description, style: AppTextStyles.bodyMedium),
                ],
                SizedBox(height: AppSpacing.sm),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onComments,
                      icon: Icon(LineIcons.comment, size: AppIconSize.sm),
                      label: Text('Comments'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
