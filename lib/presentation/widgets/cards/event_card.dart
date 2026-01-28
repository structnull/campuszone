import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/presentation/widgets/common/common.dart';
import 'package:flutter/material.dart';

/// A card widget displaying event information with image, tags, and details.
///
/// Used in the Events page to display upcoming events in a list or carousel.
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = SupabaseService.storage
        .from('events')
        .getPublicUrl('events/${event.id}/events.jpg');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.black, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(13),
              spreadRadius: 1,
              blurRadius: AppSpacing.sm,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.organizers.isNotEmpty)
              Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: event.organizers
                        .map((organizer) => AppTag(
                              label: organizer,
                              backgroundColor: AppColors.cardDark,
                              textColor: AppColors.textPrimary,
                              borderRadius: AppRadius.full,
                              padding: AppSpacing.chipPadding,
                            ))
                        .toList(),
                  )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(event.title, style: AppTextStyles.headlineSmall),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text("${event.date ?? ''} · ${event.time ?? ''}",
                  style: AppTextStyles.bodyMediumBold),
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.location_on,
                      size: AppIconSize.xs, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.xxs),
                  Text(event.location ?? '', style: AppTextStyles.caption),
                ],
              ),
            ),
            if (event.tags.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: event.tags
                      .map((tag) => AppTag(
                            label: tag,
                            backgroundColor: AppColors.cardDark,
                            textColor: AppColors.textWhite,
                            borderRadius: AppRadius.md,
                          ))
                      .toList(),
                ),
              ),
            SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
              child: AppNetworkImage(
                imageUrl: imageUrl,
                height: AppDimensions.eventImageHeight,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
