import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

/// A row of social media icon buttons.
///
/// Displays LinkedIn, Twitter/X, and Instagram icons based on available data.
class SocialIconsRow extends StatelessWidget {
  final String? linkedinUrl;
  final String? twitterUrl;
  final String? instagramUrl;

  const SocialIconsRow({
    super.key,
    this.linkedinUrl,
    this.twitterUrl,
    this.instagramUrl,
  });

  /// Creates from a socials data map (handles both List and Map formats).
  factory SocialIconsRow.fromSocialsData(dynamic socialsData) {
    Map<String, dynamic>? socials;

    if (socialsData is List && socialsData.isNotEmpty) {
      socials = socialsData.first as Map<String, dynamic>;
    } else if (socialsData is Map<String, dynamic>) {
      socials = socialsData;
    }

    return SocialIconsRow(
      linkedinUrl: socials?['linkedin'] as String?,
      twitterUrl: socials?['twitter'] as String?,
      instagramUrl: socials?['instagram'] as String?,
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: AppColors.error));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> socialIcons = [];

    void addIcon(IconData icon, String url) {
      socialIcons.add(Container(
        margin: EdgeInsets.only(right: AppSpacing.md),
        decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: AppRadius.cardRadius,
            boxShadow: [
              BoxShadow(
                  color: AppColors.primary.withValues(alpha: .1),
                  blurRadius: 8,
                  spreadRadius: 1)
            ]),
        child: IconButton(
            icon: Icon(icon, color: AppColors.primary),
            onPressed: () => _launchUrl(context, url)),
      ));
    }

    if (linkedinUrl != null && linkedinUrl!.isNotEmpty) {
      addIcon(LineIcons.linkedin, linkedinUrl!);
    }
    if (twitterUrl != null && twitterUrl!.isNotEmpty) {
      addIcon(LineIcons.twitter, twitterUrl!);
    }
    if (instagramUrl != null && instagramUrl!.isNotEmpty) {
      addIcon(LineIcons.instagram, instagramUrl!);
    }

    if (socialIcons.isEmpty) return const SizedBox.shrink();
    return Row(children: socialIcons);
  }
}
