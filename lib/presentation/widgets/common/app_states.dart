import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onAction;
  final String? actionText;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: AppIconSize.avatar, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.lg),
            Text(title,
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              SizedBox(height: AppSpacing.sm),
              Text(subtitle!,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
            ],
            if (onAction != null && actionText != null) ...[
              SizedBox(height: AppSpacing.xl),
              TextButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.message = 'Something went wrong',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: AppIconSize.avatar, color: AppColors.error),
            SizedBox(height: AppSpacing.lg),
            Text(message,
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary),
                child: Text('Retry',
                    style: AppTextStyles.buttonMedium
                        .copyWith(color: AppColors.textWhite)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
