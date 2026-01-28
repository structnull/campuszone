import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/globals.dart' as globals;
import 'package:campuszone/presentation/presentation.dart';
import 'package:campuszone/presentation/screens/profile/editprofile/profilepic/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  final UserRepository _repository = UserRepository();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = await _repository.getUserById(userId);
      if (user != null) {
        setState(() {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _collegeIdController.text = user.collegeId ?? '';
          _bioController.text = user.bio ?? '';

          if (user.socials != null) {
            _linkedinController.text = user.socials!.linkedin ?? '';
            _twitterController.text = user.socials!.twitter ?? '';
            _instagramController.text = user.socials!.instagram ?? '';
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppDialog.showError(
          context: context, message: 'Error fetching profile data');
    }
  }

  Future<void> _updateUserData() async {
    final userId = SupabaseService.currentUserId;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = await _repository.getUserById(userId);
      if (currentUser == null) throw Exception("User not found");

      final updatedUser = currentUser.copyWith(
        name: Sanitizer.text(_nameController.text),
        bio: Sanitizer.text(_bioController.text),
        collegeId: _collegeIdController.text,
        profilePicPath: '$userId/profile_picture.jpg',
      );

      final updatedSocials = SocialsModel(
        linkedin: Sanitizer.text(_linkedinController.text),
        twitter: Sanitizer.text(_twitterController.text),
        instagram: Sanitizer.text(_instagramController.text),
      );

      await Future.wait([
        _repository.updateUser(updatedUser),
        _repository.updateSocials(userId, updatedSocials),
      ]);

      // Update cache buster
      globals.globalCacheBuster.value =
          DateTime.now().millisecondsSinceEpoch.toString();

      if (!mounted) return;
      AppSnackbar.show(context, 'Profile updated successfully!');
      Navigator.pop(context, {'updated': true});
    } catch (e) {
      if (!mounted) return;
      AppDialog.showError(context: context, message: 'Error updating profile');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: AppLoader()));
    }

    final userId = SupabaseService.currentUserId ?? '';
    final profileUrl = SupabaseService.getProfilePictureUrl(userId,
        cacheBuster: globals.globalCacheBuster.value);

    return AppScaffold(
      appBar: AppAppBar(title: 'Basic Info', showBackButton: true),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProfilePicture()),
                    );
                    if (result == true) {
                      globals.globalCacheBuster.value =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      setState(() {});
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.textPrimary, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 80,
                          backgroundColor: AppColors.shimmerBase,
                          backgroundImage: NetworkImage(profileUrl),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.black,
                          child: Icon(LineIcons.camera,
                              size: 22, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              AppTextField(
                labelText: 'Name',
                controller: _nameController,
                validator: Validators.required,
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                labelText: 'Email',
                controller: _emailController,
                readOnly: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                labelText: 'CollegeID',
                controller: _collegeIdController,
                keyboardType: TextInputType.text,
                readOnly: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                labelText: 'Bio',
                controller: _bioController,
                maxLines: 4,
                maxLength: 300,
                validator: Validators.maxLength(300, 'Bio'),
              ),
              SizedBox(height: AppSpacing.xxl),
              Text('Socials', style: AppTextStyles.headlineLarge),
              Text('Add full URL of social profiles',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                labelText: 'LinkedIn',
                controller: _linkedinController,
                prefixIcon: LineIcons.linkedinIn,
                validator: Validators.url,
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                labelText: 'Twitter (X)',
                controller: _twitterController,
                prefixIcon: LineIcons.twitter,
                validator: Validators.url,
              ),
              SizedBox(height: AppSpacing.md),
              AppTextField(
                labelText: 'Instagram',
                controller: _instagramController,
                prefixIcon: LineIcons.instagram,
                validator: Validators.url,
              ),
              SizedBox(height: 80),
              AppButton(
                text: 'Save',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateUserData();
                  }
                },
                backgroundColor: AppColors.black,
                textColor: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _collegeIdController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    super.dispose();
  }
}
