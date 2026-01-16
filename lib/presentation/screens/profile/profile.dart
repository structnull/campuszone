import 'package:campuszone/presentation/screens/auth/login_page.dart';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/globals.dart';
import 'package:campuszone/presentation/screens/profile/editprofile/edit_profile.dart';
import 'package:campuszone/presentation/screens/profile/editprofile/profilepic/profile_picture.dart';
import 'package:campuszone/presentation/screens/profile/editprofile/profilepic/fullscreenpicpage.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:shimmer/shimmer.dart';
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
        duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = CurvedAnimation(
        parent: _animationController, curve: AppAnimations.defaultCurve);
    _slideAnimation = Tween<Offset>(begin: Offset(-0.5, 0), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutBack));
    _animationController.forward();
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
      _localCacheBuster = globalCacheBuster.value;
      _fetchUserData();
    }
  }

  void _fetchUserData() {
    setState(() => _userDataFuture = _getUserData());
  }

  Future<Map<String, dynamic>?> _getUserData() async {
    final user = SupabaseService.currentUser;
    if (user == null) return null;
    try {
      final response = await SupabaseService.usersTable
          .select('*, socials(*)')
          .eq('id', user.id)
          .maybeSingle();
      String profilePicUrl = SupabaseService.getProfilePictureUrl(user.id,
          cacheBuster: globalCacheBuster.value ?? _localCacheBuster);
      return {...?response, 'profile_picture_url': profilePicUrl};
    } catch (e) {
      AppLogger.error('Error fetching user data', e);
      return null;
    }
  }

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
        title:
            Text(AppStrings.confirmLogout, style: AppTextStyles.headlineSmall),
        content: Text(AppStrings.logoutConfirmMessage,
            style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppStrings.yes)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppStrings.no)),
        ],
      ),
    );
    if (shouldLogout != true) return;
    try {
      await SupabaseService.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false);
      }
    } catch (e) {
      AppLogger.error('Logout error', e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppStrings.somethingWentWrong),
            backgroundColor: AppColors.error));
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Could not launch $url'),
            backgroundColor: AppColors.error));
      }
    }
  }

  Widget _buildShimmerProfileHeader() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200, height: 30, color: AppColors.shimmerBase),
            SizedBox(height: AppSpacing.xxl),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: AppDimensions.avatarRadiusLarge),
              SizedBox(width: AppSpacing.xl),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 120, height: 16, color: AppColors.shimmerBase),
                SizedBox(height: AppSpacing.sm),
                Container(width: 150, height: 16, color: AppColors.shimmerBase),
                SizedBox(height: AppSpacing.sm),
                Container(width: 100, height: 16, color: AppColors.shimmerBase),
              ]),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.only(top: AppSpacing.sm, right: AppSpacing.sm),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                    icon: Icon(LineIcons.alternateSignOut,
                        color: AppColors.primary),
                    onPressed: () => _logout(context)),
              ]),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final newCacheBuster =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  globalCacheBuster.value = newCacheBuster;
                  _localCacheBuster = newCacheBuster;
                  _fetchUserData();
                  await Future.delayed(AppAnimations.slow);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _userDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                            height: MediaQuery.of(context).size.height - 100,
                            child: _buildShimmerProfileHeader());
                      } else if (snapshot.hasError || !snapshot.hasData) {
                        return SizedBox(
                            height: MediaQuery.of(context).size.height - 100,
                            child: Center(
                                child: Text(AppStrings.failedToLoad,
                                    style: AppTextStyles.bodyLarge)));
                      }
                      final userData = snapshot.data!;
                      final name = userData['name'] ?? AppStrings.user;
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxl,
                              vertical: AppSpacing.lg),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: ScaleTransition(
                                      scale: _scaleAnimation,
                                      child: Text(
                                          'Hello, ${name.split(' ')[0]}',
                                          style: AppTextStyles.displayLarge
                                              .copyWith(
                                                  color:
                                                      AppColors.textPrimary))),
                                ),
                                SizedBox(height: AppSpacing.xxl),
                                _buildProfileHeader(userData),
                                SizedBox(height: AppSpacing.xxl),
                                _buildSocialIcons(userData),
                                SizedBox(height: 200),
                              ]),
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
    final name = userData['name'] ?? AppStrings.user;
    final collegeId = userData['collegeid'] ?? 'Not available';
    final bio = userData['bio'] ?? '';
    final profileImage = userData['profile_picture_url'];

    return SlideTransition(
      position: _slideAnimation,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FullScreenPicture(imageUrl: profileImage),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) =>
                        FadeTransition(opacity: animation, child: child),
              )),
              onLongPress: () async {
                final result = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePicture()));
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
                    border: Border.all(color: AppColors.textWhite, width: 4.0),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: .2),
                          blurRadius: 10,
                          spreadRadius: 2)
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
                          baseColor: AppColors.shimmerBase,
                          highlightColor: AppColors.shimmerHighlight,
                          child: Container(
                              width: 200,
                              height: 200,
                              color: AppColors.shimmerBase),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                          AppAssets.profileDefault,
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.section),
          Expanded(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: AppTextStyles.displaySmall
                          .copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: AppSpacing.xs),
                  Text("collegeID: $collegeId",
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.textSecondary)),
                ]),
          ),
        ]),
        SizedBox(height: AppSpacing.xl),
        Text("bio:",
            style: AppTextStyles.displayMedium
                .copyWith(color: AppColors.textPrimary)),
        Text(bio,
            style: AppTextStyles.headlineMedium
                .copyWith(color: AppColors.textPrimary)),
        SizedBox(height: AppSpacing.xl),
        Center(
          child: SizedBox(
            height: AppDimensions.buttonHeight,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    PageRouteBuilder(
                      transitionDuration: AppAnimations.slow,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const EditProfilePage(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var tween = Tween(
                                begin: Offset(1.0, 0.0), end: Offset.zero)
                            .chain(
                                CurveTween(curve: AppAnimations.defaultCurve));
                        return SlideTransition(
                            position: animation.drive(tween), child: child);
                      },
                    ));
                if (result != null && result['updated'] == true) {
                  final newCacheBuster =
                      DateTime.now().millisecondsSinceEpoch.toString();
                  globalCacheBuster.value = newCacheBuster;
                  _localCacheBuster = newCacheBuster;
                  _fetchUserData();
                }
              },
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.textSecondary),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.fullRadius)),
              child: Text(AppStrings.editProfile,
                  style: AppTextStyles.titleMedium),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.xl),
      ]),
    );
  }

  Widget _buildSocialIcons(Map<String, dynamic> userData) {
    final socials = userData['socials'];
    final linkedin = socials?['linkedin'];
    final twitter = socials?['twitter'];
    final instagram = socials?['instagram'];
    List<Widget> socialIcons = [];
    void addSocialIcon(IconData icon, String url) {
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
            onPressed: () => _launchUrl(url)),
      ));
    }

    if (linkedin != null && linkedin.isNotEmpty) {
      addSocialIcon(LineIcons.linkedin, linkedin);
    }
    if (twitter != null && twitter.isNotEmpty) {
      addSocialIcon(LineIcons.twitter, twitter);
    }
    if (instagram != null && instagram.isNotEmpty) {
      addSocialIcon(LineIcons.instagram, instagram);
    }
    if (socialIcons.isEmpty) return const SizedBox.shrink();
    return Row(children: socialIcons);
  }
}
