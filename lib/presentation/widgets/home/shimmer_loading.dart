import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A shimmer loading placeholder widget for list views.
///
/// Used to display a loading state with animated shimmer effect.
class ShimmerLoading extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerLoading({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 150.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.builder(
        itemCount: itemCount,
        padding: EdgeInsets.all(AppSpacing.lg),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: Container(
              height: itemHeight,
              decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: AppRadius.inputRadius)),
        ),
      ),
    );
  }
}
