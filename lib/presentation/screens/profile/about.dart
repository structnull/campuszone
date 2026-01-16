import 'package:campuszone/core/core.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(title: 'About CampusZone', showBackButton: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  AppNetworkImage(
                    imageUrl:
                        'https://via.placeholder.com/150', // Replace with app logo if available
                    height: 100,
                    width: 100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Text(
                    'CampusZone',
                    style: AppTextStyles.headlineMedium,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Version 1.0.0',
                    style: AppTextStyles.caption,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Text(
                    'CampusZone is your all-in-one college companion app. Connect with peers, stay updated on events, find resources, and much more.',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            _buildInfoTile(Icons.code, 'Developed by', 'CampusZone Team'),
            _buildInfoTile(Icons.email, 'Contact', 'support@campuszone.com'),
            _buildInfoTile(Icons.privacy_tip, 'Privacy Policy', 'Tap to view'),
            _buildInfoTile(
                Icons.description, 'Terms of Service', 'Tap to view'),
            SizedBox(height: AppSpacing.xl),
            Text(
              '© ${DateTime.now().year} CampusZone. All rights reserved.',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return AppCard(
      padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelLarge),
                Text(subtitle,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
