import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:campuszone/presentation/screens/community/communityspace/community_details.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CommunitySpace extends StatefulWidget {
  const CommunitySpace({super.key});

  @override
  State<CommunitySpace> createState() => _CommunitySpaceState();
}

class _CommunitySpaceState extends State<CommunitySpace> {
  final CommunityRepository _repository = CommunityRepository();
  List<CommunityModel> _communities = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  Future<void> _fetchCommunities() async {
    try {
      final communities = await _repository.getAllCommunities();
      if (mounted) {
        setState(() {
          _communities = communities;
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  String _getShortDescription(String? description) {
    if (description == null || description.isEmpty) return '';
    final words = description.split(' ');
    if (words.length <= 8) return description;
    return '${words.take(8).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      // We assume this is a tab view or similar, so no AppBar unless needed
      // But preserving scaffold structure if it's used independently.
      // If it's a tab inside 'CommunityPage', we might not want AppScaffold with AppBar.
      // But legacy code used Scaffold. I'll use simple container or Scaffold.
      // Assuming it's a tab content usually. But AppScaffold is safe.
      backgroundColor: AppColors.scaffoldBackground,
      body: _isLoading
          ? Center(child: AppLoader())
          : _hasError
              ? AppEmptyState(
                  icon: Icons.error_outline,
                  title: 'Failed to load communities',
                  actionText: 'Retry',
                  onAction: _fetchCommunities,
                )
              : _communities.isEmpty
                  ? AppEmptyState(
                      icon: Icons.groups, title: 'No communities found')
                  : Column(
                      children: [
                        Expanded(
                          child: CarouselSlider.builder(
                            itemCount: _communities.length,
                            itemBuilder: (context, index, realIndex) {
                              final community = _communities[index];
                              return _CommunityCard(
                                community: community,
                                shortDescription:
                                    _getShortDescription(community.description),
                              );
                            },
                            options: CarouselOptions(
                              height: AppDimensions.carouselCardHeight,
                              enlargeCenterPage: true,
                              enlargeStrategy: CenterPageEnlargeStrategy.scale,
                              viewportFraction: 0.75,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 3),
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.lg),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _communities.asMap().entries.map((entry) {
                              return AnimatedContainer(
                                duration: AppAnimations.normal,
                                width: _currentIndex == entry.key
                                    ? AppSpacing.lg
                                    : AppSpacing.sm,
                                height: AppSpacing.sm,
                                margin: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.tiny),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.tiny),
                                  color: _currentIndex == entry.key
                                      ? AppColors.black
                                      : Colors.grey[300],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final String shortDescription;

  const _CommunityCard({
    required this.community,
    required this.shortDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'community-${community.id}',
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: EdgeInsets.symmetric(
              vertical: AppSpacing.lg, horizontal: AppSpacing.xxs),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CommunityDetailPage(community: community),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: AppCard(
              padding: EdgeInsets.zero,
              // elevation uses default card elevation
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      AppNetworkImage(
                        imageUrl: community.imageUrl ?? '',
                        height: AppDimensions.communityImageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppRadius.md)),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: AppDimensions.gradientOverlayHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.black.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (community.membersCount != null)
                        Positioned(
                          top: AppSpacing.snackbar,
                          right: AppSpacing.snackbar,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: .6),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people,
                                    color: AppColors.white,
                                    size: AppIconSize.xs),
                                SizedBox(width: AppSpacing.xs),
                                Text(
                                  community.membersCount!,
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            community.name,
                            style: AppTextStyles.titleLarge,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (shortDescription.isNotEmpty) ...[
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              shortDescription,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.textSecondary),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ]
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
