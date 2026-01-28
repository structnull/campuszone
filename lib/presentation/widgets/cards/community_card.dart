import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/presentation/widgets/common/common.dart';
import 'package:flutter/material.dart';

/// A card widget displaying community information with image and member count.
///
/// Used in the Community Space page to display communities in a carousel.
class CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final String shortDescription;
  final VoidCallback? onTap;

  const CommunityCard({
    super.key,
    required this.community,
    required this.shortDescription,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'community-${community.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: EdgeInsets.symmetric(
              vertical: AppSpacing.lg, horizontal: AppSpacing.xxs),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      AppNetworkImage(
                        imageUrl: community.imageUrl ?? '',
                        height: AppDimensions.communityImageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppRadius.md)),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: AppDimensions.gradientOverlayHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (community.membersCount != null)
                        Positioned(
                          top: AppSpacing.snackbar,
                          right: AppSpacing.snackbar,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: .6),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people,
                                    color: AppColors.white,
                                    size: AppIconSize.xs),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  community.membersCount!,
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            community.name,
                            style: AppTextStyles.titleLarge,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (shortDescription.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              shortDescription,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
