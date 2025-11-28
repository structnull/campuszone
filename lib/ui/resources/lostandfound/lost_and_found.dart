import 'package:campuszone/globals.dart' as globals;
import 'package:campuszone/ui/profile/editprofile/profilepic/fullscreenpicpage.dart';
import 'package:campuszone/ui/resources/comments/comments.dart';
import 'package:campuszone/ui/resources/lostandfound/upload_data.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

class LostAndFoundPage extends StatefulWidget {
  const LostAndFoundPage({super.key});

  @override
  State<LostAndFoundPage> createState() => _LostAndFoundPageState();
}

class _LostAndFoundPageState extends State<LostAndFoundPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  double _loadingProgress = 0.0;
  List<dynamic> _posts = [];
  late AnimationController _animationController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fetchPosts();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchPosts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadingProgress = 0.0;
    });

    try {
      // Simulate progressive loading
      final progressTimer =
          Stream.periodic(const Duration(milliseconds: 100), (i) => i)
              .take(10)
              .listen((i) {
        if (mounted) {
          setState(() {
            _loadingProgress = (i + 1) / 10;
          });
        }
      });

      final data =
          await Supabase.instance.client.from('lostandfound').select('''
            *,
            user:users ( id, name, email )
          ''').order('created_at', ascending: false);

      await progressTimer.cancel();

      if (mounted) {
        setState(() {
          _posts = data as List<dynamic>;
          _isLoading = false;
          _loadingProgress = 1.0;
        });
        _animationController.forward(from: 0.0);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProgress = 0.0;
        });
        _showErrorDialog('Failed to load posts. Please try again.');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(LineIcons.exclamationCircle, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Error', style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.black)),
          ),
        ],
        elevation: 10,
      ),
    );
  }

  Future<void> _confirmDelete(dynamic post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(LineIcons.trash, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('Confirm Delete'),
          ],
        ),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete'),
          ),
        ],
        elevation: 10,
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      try {
        _showLoadingSnackBar('Deleting post...');
        final String? imagePath = post['image_path'] as String?;
        if (imagePath != null && imagePath.isNotEmpty) {
          debugPrint('Deleting image from storage: $imagePath');
          await Supabase.instance.client.storage
              .from('lostandfound')
              .remove([imagePath]);
        }

        debugPrint('Deleting post with item_id: ${post['item_id']}');
        await Supabase.instance.client
            .from('lostandfound')
            .delete()
            .eq('item_id', post['item_id']);

        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(LineIcons.check, color: Colors.white),
                SizedBox(width: 8),
                Text('Post deleted successfully.'),
              ],
            ),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );

        _fetchPosts();
      } catch (error) {
        debugPrint('Error deleting post: ${error.toString()}');
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          _showErrorDialog('Error deleting post. Please try again.');
        }
      }
    }
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
        backgroundColor: Colors.black,
        duration: const Duration(seconds: 60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _openCommentsPage(String lostAndFoundId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommentsPage(
          entityId: lostAndFoundId,
          entityType: 'lostandfound',
        ),
      ),
    );
  }

  void _openFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenPicture(imageUrl: imageUrl),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min ago';
      }
      return '${difference.inHours} hr ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

// Profile picture builder using globalCacheBuster and Image.network
  Widget _buildProfilePic(String userId, Map<String, dynamic> post) {
    final baseUrl = Supabase.instance.client.storage
        .from('profilepic')
        .getPublicUrl('$userId/profile_picture.jpg');
    final String profileUrl = (globals.globalCacheBuster.value ?? '').isNotEmpty
        ? '$baseUrl?cacheBuster=${globals.globalCacheBuster.value}'
        : baseUrl;

    return Hero(
      tag:
          'profile1-${post['item_id']}-$userId${globals.globalCacheBuster.value ?? ""}',
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black.withAlpha(51),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            profileUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lost and Found',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Excalifont',
            fontSize: 32,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      floatingActionButton: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const UploadDataPage(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final tween =
                      Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                          .chain(CurveTween(curve: Curves.easeOutCubic));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 400),
              ),
            ).then((result) {
              if (result == true) {
                _refreshIndicatorKey.currentState?.show();
              }
            });
          },
          backgroundColor: Colors.black,
          elevation: 6,
          child: const Icon(LineIcons.plus, color: Colors.white, size: 28),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _fetchPosts,
            color: Colors.black,
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: 5,
                    itemBuilder: (context, index) => _buildLoadingCard(),
                  )
                : _posts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LineIcons.search,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              'No posts found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Be the first to post a lost or found item!',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                          itemCount: _posts.length,
                          itemBuilder: (context, index) {
                            final post = _posts[index];
                            final Map<String, dynamic>? user =
                                post['user'] as Map<String, dynamic>?;
                            final String userName =
                                user?['name'] ?? 'Unknown User';

                            // Get post image URL
                            final String? filePath =
                                post['image_path'] as String?;
                            String? imageUrl;
                            if (filePath != null && filePath.isNotEmpty) {
                              imageUrl = Supabase.instance.client.storage
                                  .from('lostandfound')
                                  .getPublicUrl(filePath);
                              if ((globals.globalCacheBuster.value ?? '')
                                  .isNotEmpty) {
                                imageUrl =
                                    '$imageUrl?t=${globals.globalCacheBuster.value}';
                              }
                            }

                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 500),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: Card(
                                    elevation: 4,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 1),
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // User info row with timestamp
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              (user != null &&
                                                      user['id'] != null)
                                                  ? _buildProfilePic(
                                                      user['id'], post)
                                                  : Container(
                                                      width: 48,
                                                      height: 48,
                                                      color: Colors.grey,
                                                    ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      userName,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      _formatDate(
                                                          post['created_at']),
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Post image section (clickable for full-screen)
                                        if (imageUrl != null &&
                                            imageUrl.isNotEmpty)
                                          GestureDetector(
                                            onTap: () =>
                                                _openFullScreenImage(imageUrl!),
                                            child: Hero(
                                              tag:
                                                  'image_${post['item_id']}_$index',
                                              child: Container(
                                                height: 250,
                                                color: Colors.black,
                                                child: Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Shimmer.fromColors(
                                                      baseColor:
                                                          Colors.grey[300]!,
                                                      highlightColor:
                                                          Colors.grey[100]!,
                                                      child: Container(
                                                        color: Colors.white,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      height: 250,
                                                      color: Colors.grey[300],
                                                      child: const Center(
                                                        child: Icon(
                                                          LineIcons
                                                              .exclamationCircle,
                                                          size: 50,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        // Caption area
                                        Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                post['title'] ?? 'No Title',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                post['description'] ?? '',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              if (post['location'] != null &&
                                                  post['location']
                                                      .toString()
                                                      .isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                          LineIcons.mapMarker,
                                                          size: 16,
                                                          color: Colors.grey),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        post['location']
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                          fontStyle:
                                                              FontStyle.italic,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              const Divider(height: 24),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  _buildActionButton(
                                                    icon: LineIcons.comment,
                                                    label: 'Comments',
                                                    onTap: () =>
                                                        _openCommentsPage(
                                                            post['item_id']
                                                                .toString()),
                                                  ),
                                                  if (currentUserId != null &&
                                                      post['user_id'] ==
                                                          currentUserId)
                                                    _buildActionButton(
                                                      icon: LineIcons.trash,
                                                      label: 'Delete',
                                                      color: Colors.red,
                                                      onTap: () =>
                                                          _confirmDelete(post),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
          if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                value: _loadingProgress,
                backgroundColor: Colors.grey[300],
                color: Colors.black,
                minHeight: 4,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 10,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    height: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
