import 'package:campuszone/chat/chatmsgpage.dart';
import 'package:campuszone/globals.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:line_icons/line_icons.dart';

class ProfileLinkPage extends StatefulWidget {
  final String userId;

  const ProfileLinkPage({
    super.key,
    required this.userId,
  });

  @override
  State<ProfileLinkPage> createState() => _ProfileLinkPageState();
}

class _ProfileLinkPageState extends State<ProfileLinkPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _socialData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;

      // Fetch user data.
      final userResponse = await supabase
          .from('users')
          .select('*')
          .eq('id', widget.userId)
          .maybeSingle();

      if (!mounted) return; // Check if the widget is still in the tree.
      setState(() {
        _userData = userResponse;
      });

      // Fetch social links.
      final socialResponse = await supabase
          .from('socials')
          .select('*')
          .eq('id', widget.userId)
          .single();

      if (!mounted) return;
      setState(() {
        _socialData = socialResponse;
      });

      // Get profile picture URL.
      supabase.storage
          .from('profilepic')
          .getPublicUrl('${widget.userId}/profile_picture.jpg');
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);

    // Check if there is an app to handle this URL.
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('No application can handle this request: $url')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading ? _buildShimmerProfilePage() : _buildProfilePage(),
    );
  }

  Widget _buildShimmerProfilePage() {
    // A minimalist shimmer that scales with the screen size.
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture wrapped with ValueListenableBuilder
              ValueListenableBuilder<String?>(
                valueListenable: globalCacheBuster,
                builder: (context, cacheBuster, child) {
                  final supabase = Supabase.instance.client;
                  final String baseUrl = supabase.storage
                      .from('profilepic')
                      .getPublicUrl('${widget.userId}/profile_picture.jpg');
                  final String updatedUrl =
                      (cacheBuster != null && cacheBuster.isNotEmpty)
                          ? '$baseUrl?cacheBuster=$cacheBuster'
                          : baseUrl;
                  return Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: updatedUrl.isNotEmpty
                            ? NetworkImage(updatedUrl)
                            : const AssetImage('assets/profile_pic.png')
                                as ImageProvider,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Full Name.
              Text(
                _userData?['name'] ?? 'User',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // College ID.
              Text(
                '@${_userData?['collegeid'] ?? 'College ID'}',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              // Joined Date.
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LineIcons.calendarAlt,
                      color: Colors.white70, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _userData?['created_at'] != null
                        ? 'Joined ${timeago.format(DateTime.parse(_userData!['created_at']))}'
                        : 'Joined Recently',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Message Button.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(width: 4, color: Colors.white70),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(48),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatMessagePage(user: _userData),
                      ),
                    );
                  },
                  child: Text(
                    'Message',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.white24),
              const SizedBox(height: 20),
              // About Section.
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'About:',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _userData?['bio'] ?? 'No bio provided.',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                  height: 1.6,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 30),
              // Socials Section.
              if (_socialData != null &&
                  (_socialData?['linkedin'] != null ||
                      _socialData?['instagram'] != null ||
                      _socialData?['twitter'] != null)) ...[
                const Divider(color: Colors.white24),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Socials',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_socialData?['linkedin'] != null)
                      IconButton(
                        icon: const Icon(LineIcons.linkedin,
                            size: 32, color: Colors.white),
                        onPressed: () => _launchURL(_socialData!['linkedin']),
                      ),
                    if (_socialData?['instagram'] != null)
                      IconButton(
                        icon: const Icon(LineIcons.instagram,
                            size: 32, color: Colors.white),
                        onPressed: () => _launchURL(_socialData!['instagram']),
                      ),
                    if (_socialData?['twitter'] != null)
                      IconButton(
                        icon: const Icon(LineIcons.twitter,
                            size: 32, color: Colors.white),
                        onPressed: () => _launchURL(_socialData!['twitter']),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
