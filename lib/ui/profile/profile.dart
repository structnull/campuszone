import 'package:campuszone/auth/login_page.dart';
import 'package:campuszone/globals.dart';
import 'package:campuszone/ui/profile/editprofile/edit_profile.dart';
import 'package:campuszone/ui/profile/editprofile/profilepic/profile_picture.dart';
import 'package:campuszone/ui/profile/editprofile/profilepic/fullscreenpicpage.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  Future<Map<String, dynamic>?>? _userDataFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  String? _localCacheBuster;

  @override
  void initState() {
    super.initState();
    _localCacheBuster = globalCacheBuster.value;
    _fetchUserData();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();

    // Listen to global cache buster changes
    globalCacheBuster.addListener(_handleCacheBusterChange);
  }

  @override
  void dispose() {
    _animationController.dispose();
    globalCacheBuster.removeListener(_handleCacheBusterChange);
    super.dispose();
  }

  void _handleCacheBusterChange() {
    if (mounted && _localCacheBuster != globalCacheBuster.value) {
      setState(() {
        _localCacheBuster = globalCacheBuster.value;
        _fetchUserData();
      });
    }
  }

  void _fetchUserData() {
    setState(() {
      _userDataFuture = _getUserData();
    });
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    try {
      // Fetch the user data along with the related socials data
      final response = await supabase
          .from('users')
          .select('*, socials(*)')
          .eq('id', user.id)
          .maybeSingle();

      String profilePicUrl = supabase.storage
          .from('profilepic')
          .getPublicUrl('${user.id}/profile_picture.jpg');

      // Use the latest cache buster value
      final cacheBuster = globalCacheBuster.value ?? _localCacheBuster;
      if (cacheBuster != null) {
        profilePicUrl = '$profilePicUrl?t=$cacheBuster';
      }

      return {
        ...?response,
        'profile_picture_url': profilePicUrl,
      };
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final supabase = Supabase.instance.client;
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await supabase.auth.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Helper to launch URLs safely
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildShimmerProfileHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200, height: 30, color: Colors.white),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 50,
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 150, height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: 100, height: 16, color: Colors.white),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Top row with Settings & Logout icons
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(LineIcons.alternateSignOut,
                        color: Colors.black),
                    onPressed: () => _logout(context),
                  ),
                ],
              ),
            ),
            // Expanded area for the rest of the content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final newCacheBuster =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  globalCacheBuster.value = newCacheBuster;
                  _localCacheBuster = newCacheBuster;
                  _fetchUserData();
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _userDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Shimmer placeholder
                        return SizedBox(
                          height: MediaQuery.of(context).size.height - 100,
                          child: _buildShimmerProfileHeader(),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height - 100,
                          child: const Center(
                            child: Text('Failed to load user data'),
                          ),
                        );
                      }

                      final userData = snapshot.data!;
                      final name = userData['name'] ?? 'User';

                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hello Username
                              SlideTransition(
                                position: _slideAnimation,
                                child: ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Text(
                                    'Hello, ${name.split(' ')[0]}',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Excalifont',
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              // Profile Picture and details
                              _buildProfileHeader(userData),
                              const SizedBox(height: 24),
                              // Social Icons (only rendered once)
                              _buildSocialIcons(userData),
                              const SizedBox(height: 200),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> userData) {
    final name = userData['name'] ?? 'User';
    final collegeId = userData['collegeid'] ?? 'Not available';
    final bio = userData['bio'] ?? '';
    final profileImage = userData['profile_picture_url'];

    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with profile picture on the left and name/college id on the right
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture
              ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FullScreenPicture(imageUrl: profileImage),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                              opacity: animation, child: child);
                        },
                      ),
                    );
                  },
                  onLongPress: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfilePicture()),
                    );
                    if (result == true) {
                      final newCacheBuster =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      globalCacheBuster.value = newCacheBuster;
                      _localCacheBuster = newCacheBuster;
                      _fetchUserData();
                    }
                  },
                  child: Hero(
                    tag: 'profile-pic',
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          profileImage,
                          key: ValueKey(_localCacheBuster),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 200,
                                height: 200,
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            'assets/profile.png',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 50),
              // Name and college id centered with respect to the picture
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "collegeID: $collegeId",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "bio:",
            style: const TextStyle(
              fontSize: 40,
              fontFamily: 'Excalifont',
              color: Colors.black87,
            ),
          ),
          // Bio text with "Excalifont" and bigger font
          Text(
            bio,
            style: const TextStyle(
              fontSize: 32,
              fontFamily: 'Excalifont',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          // Edit Profile Button with a larger height and font size
          Center(
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 500),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const EditProfilePage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        const begin = Offset(1.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.easeInOutCubic;
                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));
                        var offsetAnimation = animation.drive(tween);
                        return SlideTransition(
                            position: offsetAnimation, child: child);
                      },
                    ),
                  );
                  if (result != null && result['updated'] == true) {
                    final newCacheBuster =
                        DateTime.now().millisecondsSinceEpoch.toString();
                    globalCacheBuster.value = newCacheBuster;
                    _localCacheBuster = newCacheBuster;
                    _fetchUserData();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Removed duplicate social icons from here.
        ],
      ),
    );
  }

  Widget _buildSocialIcons(Map<String, dynamic> userData) {
    // Access socials data from the joined table.
    final socials = userData['socials'];
    // For one-to-many, you might need: final socials = (userData['socials'] as List).first;
    final linkedin = socials?['linkedin'];
    final twitter = socials?['twitter'];
    final instagram = socials?['instagram'];

    List<Widget> socialIcons = [];

    if (linkedin != null && linkedin.isNotEmpty) {
      socialIcons.add(
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(LineIcons.linkedin, color: Colors.black),
            onPressed: () => _launchUrl(linkedin),
          ),
        ),
      );
    }

    if (twitter != null && twitter.isNotEmpty) {
      socialIcons.add(
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(LineIcons.twitter, color: Colors.black),
            onPressed: () => _launchUrl(twitter),
          ),
        ),
      );
    }

    if (instagram != null && instagram.isNotEmpty) {
      socialIcons.add(
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(LineIcons.instagram, color: Colors.black),
            onPressed: () => _launchUrl(instagram),
          ),
        ),
      );
    }

    if (socialIcons.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(children: socialIcons);
  }
}
