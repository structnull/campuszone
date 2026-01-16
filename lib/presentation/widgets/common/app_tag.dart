import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

class AppTag extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const AppTag({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.padding,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.cardDark,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: textColor ?? AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
