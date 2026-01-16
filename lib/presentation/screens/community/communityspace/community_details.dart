import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CommunityDetailPage extends StatelessWidget {
  final CommunityModel community;

  const CommunityDetailPage({super.key, required this.community});

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          AppSnackbar.show(context, 'Could not launch $url', isError: true);
        }
      } else {
        if (context.mounted) {
          AppSnackbar.show(context, 'Joining community...');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.show(context, 'Error launching URL', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppAppBar(
        title: '',
        backgroundColor: Colors.transparent,
        showBackButton: true,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'community-${community.id}',
                  child: AppNetworkImage(
                    imageUrl: community.imageUrl ?? '',
                    height: MediaQuery.of(context).size.height * 0.35,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.black.withValues(alpha: 0.8),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: Text(
                    community.name,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: AppColors.white, shadows: [
                      Shadow(
                          offset: Offset(0, 2),
                          blurRadius: 4,
                          color: AppColors.black.withValues(alpha: 0.5))
                    ]),
                  ),
                ),
              ],
            ),
            Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: BoxDecoration(
                color: AppColors.scaffoldBackground,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(Icons.info_outline, 'About'),
                    SizedBox(height: AppSpacing.md),
                    AppCard(
                      child: Text(
                        community.description ?? 'No description available.',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    _buildSectionHeader(Icons.people_outline, 'Community'),
                    SizedBox(height: AppSpacing.md),

                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.cardRadius,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.groups, 'Members',
                              community.membersCount ?? '0'),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    AppButton(
                      text: '${community.name} Website',
                      icon: Icons.link,
                      isOutlined: true,
                      onPressed: () {
                        if (community.url != null) {
                          _launchUrl(context, community.url!);
                        } else {
                          AppSnackbar.show(context, 'No URL available',
                              isError: true);
                        }
                      },
                    ),
                    SizedBox(height: 20), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
        SizedBox(width: 12),
        Text(title, style: AppTextStyles.titleLarge),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.black, size: 24),
        SizedBox(height: 8),
        Text(value, style: AppTextStyles.titleMedium),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
