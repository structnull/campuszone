import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/presentation/widgets/common/common.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// A card widget displaying note information with actions.
///
/// Used in the Notes page to display individual note items.
class NoteCard extends StatelessWidget {
  final NoteModel note;
  final bool isCurrentUser;
  final VoidCallback onDelete;
  final VoidCallback onOpen;
  final VoidCallback onComments;

  const NoteCard({
    super.key,
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
