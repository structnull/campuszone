import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer loading placeholder for the profile header.
///
/// Used to display a loading state while profile data is being fetched.
class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200, height: 30, color: AppColors.shimmerBase),
            SizedBox(height: AppSpacing.xxl),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: AppDimensions.avatarRadiusLarge),
              SizedBox(width: AppSpacing.xl),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 120, height: 16, color: AppColors.shimmerBase),
                SizedBox(height: AppSpacing.sm),
                Container(width: 150, height: 16, color: AppColors.shimmerBase),
                SizedBox(height: AppSpacing.sm),
                Container(width: 100, height: 16, color: AppColors.shimmerBase),
              ]),
            ]),
          ],
        ),
      ),
    );
  }
}
