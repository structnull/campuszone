import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: elevation ?? AppElevation.card,
        color: backgroundColor ?? AppColors.cardBackground,
        shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? AppRadius.featureCardRadius),
        child: Padding(
          padding: padding ?? EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

class AppDarkCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  const AppDarkCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppElevation.card,
        color: AppColors.cardDark,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.featureCardRadius),
        margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Padding(
          padding: padding ?? EdgeInsets.all(AppSpacing.lg),
          child: child,
        ),
      ),
    );
  }
}

class AppFeatureCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final IconData? trailingIcon;

  const AppFeatureCard({
    super.key,
    required this.title,
    this.onTap,
    this.trailingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return AppDarkCard(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.headlineMedium
                  .copyWith(color: AppColors.textWhite),
            ),
          ),
          if (trailingIcon != null)
            Icon(trailingIcon,
                color: AppColors.textWhite, size: AppIconSize.lg),
        ],
      ),
    );
  }
}
