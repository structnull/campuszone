import 'package:campuszone/ui/community/communityspace/community_details.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shimmer/shimmer.dart';

// Community model definition
class Community {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? url;
  final String? membersCount;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.url,
    required this.membersCount,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      url: json['url'] as String?,
      membersCount: json['member_c'] as String?,
    );
  }
}

String _getShortDescription(String? description) {
  if (description == null || description.isEmpty) return '';
  final words = description.split(' ');
  if (words.length <= 8) return description;
  return '${words.take(8).join(' ')}...';
}

class CommunitySpace extends StatefulWidget {
  const CommunitySpace({super.key});

  @override
  _CommunitySpaceState createState() => _CommunitySpaceState();
}

class _CommunitySpaceState extends State<CommunitySpace> {
  List<Community> _communities = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentIndex = 0;
  final Map<String, String> _imageUrlCache = {};

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  String _getImageUrl(String communityId) {
    if (_imageUrlCache.containsKey(communityId)) {
      return _imageUrlCache[communityId]!;
    }

    final supabase = Supabase.instance.client;
    final url =
        supabase.storage.from('community').getPublicUrl('$communityId.png');
    _imageUrlCache[communityId] = url;
    return url;
  }

  Future<void> _fetchCommunities() async {
    final supabase = Supabase.instance.client;
    try {
      final data = await supabase.from('community').select();
      final communities =
          (data as List).map((json) => Community.fromJson(json)).toList();

      // Preload image URLs to avoid flickering
      for (var community in communities) {
        _getImageUrl(community.id);
      }

      setState(() {
        _communities = communities;
        _isLoading = false;
        _hasError = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildShimmerEffect()
          : _hasError
              ? _buildErrorWidget()
              : _communities.isEmpty
                  ? const Center(child: Text('No communities found.'))
                  : Column(
                      children: [
                        Expanded(
                          child: CarouselSlider.builder(
                            itemCount: _communities.length,
                            itemBuilder: (context, index, realIndex) {
                              final community = _communities[index];
                              return _CommunityCard(
                                community: community,
                                imageUrl: _getImageUrl(community.id),
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
                        // Carousel indicators
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
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildShimmerEffect() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade100,
            period: const Duration(seconds: 2),
            child: Container(
              height: 270,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return Container(
                width: index == 0 ? 16.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: index == 0 ? Colors.black : Colors.grey.shade300,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 50, color: Colors.grey.shade800),
          const SizedBox(height: 16),
          Text(
            'Failed to load communities.',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchCommunities,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final Community community;
  final String imageUrl;

  const _CommunityCard({
    required this.community,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'community-${community.id}',
      child: Material(
        type: MaterialType.transparency,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 300;
            return Container(
              height: 270,
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
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black.withValues(alpha: .2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            Image.network(
                              imageUrl,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                      color: Colors.black26,
                                    ),
                                  ),
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;

                                return Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade100,
                                  child: Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                            // Gradient overlay
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
                                      Colors.black.withValues(alpha: 0.4),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Members count badge
                            if (community.membersCount != null)
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: .6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.people,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        community.membersCount!,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(isSmallScreen ? 10.0 : 14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              community.name,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (community.description != null)
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  _getShortDescription(community.description),
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 10 : 14,
                                    color: Colors.black54,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
