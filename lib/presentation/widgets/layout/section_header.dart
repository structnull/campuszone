import 'package:campuszone/core/core.dart';
import 'package:campuszone/presentation/widgets/common/squiggly_divider.dart';
import 'package:flutter/material.dart';

/// A reusable section header with title and optional squiggly divider.
///
/// Used for page sections like "Resources", "Useful Links", etc.
class SectionHeader extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final bool showDivider;
  final double dividerWidth;
  final double dividerHeight;

  const SectionHeader({
    super.key,
    required this.title,
    this.titleStyle,
    this.showDivider = true,
    this.dividerWidth = 200,
    this.dividerHeight = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(
              child: Text(title,
                  style: titleStyle ??
                      AppTextStyles.displayLarge
                          .copyWith(color: AppColors.textPrimary))),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: SquigglyDivider(
                color: AppColors.primary,
                width: dividerWidth,
                height: dividerHeight),
          ),
      ],
    );
  }
}
