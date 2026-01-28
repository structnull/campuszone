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
                              return CommunityCard(
                                community: community,
                                shortDescription:
                                    _getShortDescription(community.description),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CommunityDetailPage(
                                        community: community),
                                  ),
                                ),
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
