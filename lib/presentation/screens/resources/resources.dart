import 'package:campuszone/core/core.dart';
import 'package:campuszone/presentation/widgets/common/squiggly_divider.dart';
import 'package:campuszone/presentation/screens/resources/lostandfound/lost_and_found.dart';
import 'package:campuszone/presentation/screens/resources/notes/notes.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchLinks() async {
    try {
      final List<dynamic> response =
          await SupabaseService.usefulLinksTable.select('name, link');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      AppLogger.error('Failed to fetch links', error);
      throw Exception(AppStrings.failedToLoad);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchLinks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text(AppStrings.errorLoadingData,
                            style: AppTextStyles.bodyLarge));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text('No links found',
                            style: AppTextStyles.bodyLarge));
                  }
                  final linksData = snapshot.data!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeaderSection(),
                            _buildLostAndFoundCard(context),
                            _buildNotesCard(context),
                            SizedBox(height: AppSpacing.lg),
                            _buildUsefulLinksHeader(),
                            ..._buildUsefulLinks(context, linksData),
                            SizedBox(height: AppDimensions.gradientHeight),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(
              child: Text(AppStrings.resources,
                  style: AppTextStyles.displayLarge
                      .copyWith(color: AppColors.textPrimary))),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child:
              SquigglyDivider(color: AppColors.primary, width: 200, height: 50),
        ),
      ],
    );
  }

  Widget _buildLostAndFoundCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const LostAndFoundPage())),
      child: Card(
        elevation: AppElevation.card,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.featureCardRadius),
        color: AppColors.cardDark,
        margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
              child: Text(AppStrings.lostAndFoundSection,
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.textWhite))),
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (_) => const NotesPage())),
      child: Card(
        elevation: AppElevation.card,
        shape:
            RoundedRectangleBorder(borderRadius: AppRadius.featureCardRadius),
        color: AppColors.cardDark,
        margin: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Center(
              child: Text(AppStrings.notesSection,
                  style: AppTextStyles.headlineMedium
                      .copyWith(color: AppColors.textWhite))),
        ),
      ),
    );
  }

  Widget _buildUsefulLinksHeader() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(
              child: Text(AppStrings.usefulLinks,
                  style: AppTextStyles.headlineLarge
                      .copyWith(color: AppColors.textPrimary))),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child:
              SquigglyDivider(color: AppColors.primary, width: 200, height: 50),
        ),
      ],
    );
  }

  List<Widget> _buildUsefulLinks(
      BuildContext context, List<Map<String, dynamic>> linksData) {
    return linksData.map((data) {
      return GestureDetector(
        onTap: () => _openLink(context, data['link'] as String),
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
                    child: Text(data['name'] as String,
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
    }).toList();
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }
}
