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
                              height: 400,
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
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: _communities.asMap().entries.map((entry) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: _currentIndex == entry.key ? 16.0 : 8.0,
                                height: 8.0,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
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
          margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
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
            borderRadius: BorderRadius.circular(16),
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
                        height: 180,
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
                          height: 50,
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
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.black.withValues(alpha: .6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.people,
                                    color: AppColors.white, size: 16),
                                SizedBox(width: 4),
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
                            SizedBox(height: 8),
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
