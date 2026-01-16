import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppLoader extends StatelessWidget {
  final Color? color;
  final double? size;

  const AppLoader({super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size ?? 40,
        height: size ?? 40,
        child: CircularProgressIndicator(
          color: color ?? AppColors.primary,
          strokeWidth: AppDimensions.loaderStrokeWidth,
        ),
      ),
    );
  }
}

class AppShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const AppShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: borderRadius ?? AppRadius.cardRadius,
        ),
      ),
    );
  }
}

class AppShimmerCircle extends StatelessWidget {
  final double radius;

  const AppShimmerCircle({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child:
          CircleAvatar(radius: radius, backgroundColor: AppColors.shimmerBase),
    );
  }
}

class AppShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const AppShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: AppShimmerBox(width: double.infinity, height: itemHeight),
      ),
    );
  }
}
