import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

/// A large tappable card for featuring main navigation items.
///
/// Used in the Resources page for Lost & Found and Notes cards.
class FeatureCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const FeatureCard({
    super.key,
    required this.title,
    required this.onTap,
    this.backgroundColor,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppElevation.card,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.featureCardRadius),
        color: backgroundColor ?? AppColors.cardDark,
        margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
              child: Text(title,
                  style: textStyle ??
                      AppTextStyles.headlineMedium
                          .copyWith(color: AppColors.textWhite))),
        ),
      ),
    );
  }
}
