import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

/// A card widget for displaying useful links with tap action.
///
/// Used in the Resources page to display external link items.
class UsefulLinkCard extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const UsefulLinkCard({
    super.key,
    required this.name,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppElevation.card,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.featureCardRadius),
        color: AppColors.cardDark,
        margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: AppSpacing.lg),
                  child: Text(name,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.textWhite)),
                ),
              ),
              Icon(LineIcons.alternateExternalLink,
                  color: AppColors.textWhite, size: AppIconSize.lg),
            ],
          ),
        ),
      ),
    );
  }
}
