import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/globals.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:campuszone/presentation/screens/chat/chatmsgpage.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeago/timeago.dart' as timeago;

class ProfileLinkPage extends StatefulWidget {
  final String userId;

  const ProfileLinkPage({super.key, required this.userId});

  @override
  State<ProfileLinkPage> createState() => _ProfileLinkPageState();
}

class _ProfileLinkPageState extends State<ProfileLinkPage> {
  bool _isLoading = true;
  UserModel? _user;
  final UserRepository _repository = UserRepository();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _repository.getUserById(widget.userId);
      if (mounted) {
        setState(() {
          _user = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppDialog.showError(
            context: context, message: 'Failed to load profile');
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        AppSnackbar.show(context, 'Could not launch $url', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.black,
      appBar: AppAppBar(
        title: 'Profile',
        showBackButton: true,
        backgroundColor: AppColors.black,
        textColor: AppColors.white,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      body: _isLoading
          ? Center(child: AppLoader(color: AppColors.white))
          : _user == null
              ? AppEmptyState(title: "User not found", icon: LineIcons.user)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ValueListenableBuilder<String?>(
                            valueListenable: globalCacheBuster,
                            builder: (context, cacheBuster, _) {
                              final url = SupabaseService.getProfilePictureUrl(
                                  widget.userId,
                                  cacheBuster: cacheBuster);
                              return Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.white, width: 4),
                                ),
                                child: AppAvatar(
                                  imageUrl: url,
                                  radius: 100,
                                ),
                              );
                            }),
                        const SizedBox(height: 24),
                        Text(
                          _user!.name,
                          style: AppTextStyles.headlineLarge
                              .copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@${_user!.collegeId}',
                          style: AppTextStyles.titleMedium.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(LineIcons.calendarAlt,
                                color: AppColors.white.withValues(alpha: 0.7),
                                size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Joined ${timeago.format(_user!.createdAt)}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color:
                                      AppColors.white.withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            text: "Message",
                            onPressed: () {
                              if (_user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ChatMessagePage(user: _user!)),
                                );
                              }
                            },
                            isOutlined: true,
                            backgroundColor: AppColors.white,
                            textColor: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Divider(color: AppColors.white.withValues(alpha: 0.24)),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("About:",
                              style: AppTextStyles.headlineMedium
                                  .copyWith(color: AppColors.white)),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          (_user!.bio == null || _user!.bio!.isEmpty)
                              ? 'No bio provided.'
                              : _user!.bio!,
                          style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white.withValues(alpha: 0.7)),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 30),
                        if (_user!.socials != null &&
                            (_user!.socials!.linkedin != null ||
                                _user!.socials!.instagram != null ||
                                _user!.socials!.twitter != null)) ...[
                          Divider(
                              color: AppColors.white.withValues(alpha: 0.24)),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Socials",
                                style: AppTextStyles.titleLarge
                                    .copyWith(color: AppColors.white)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_user!.socials!.linkedin != null)
                                IconButton(
                                    icon: Icon(LineIcons.linkedin,
                                        size: 32, color: AppColors.white),
                                    onPressed: () =>
                                        _launchURL(_user!.socials!.linkedin!)),
                              if (_user!.socials!.instagram != null)
                                IconButton(
                                    icon: Icon(LineIcons.instagram,
                                        size: 32, color: AppColors.white),
                                    onPressed: () =>
                                        _launchURL(_user!.socials!.instagram!)),
                              if (_user!.socials!.twitter != null)
                                IconButton(
                                    icon: Icon(LineIcons.twitter,
                                        size: 32, color: AppColors.white),
                                    onPressed: () =>
                                        _launchURL(_user!.socials!.twitter!)),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                ),
    );
  }
}
