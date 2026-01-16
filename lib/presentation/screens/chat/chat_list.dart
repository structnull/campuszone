import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/presentation/layout/layout.dart';
import 'package:campuszone/presentation/screens/chat/chatmsgpage.dart';
import 'package:campuszone/presentation/screens/profile/profilelink.dart';
import 'package:campuszone/presentation/widgets/common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class ChatPageList extends StatefulWidget {
  const ChatPageList({super.key});

  @override
  State<ChatPageList> createState() => _ChatPageListState();
}

class _ChatPageListState extends State<ChatPageList> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  final UserRepository _repository = UserRepository();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _repository.getAllUsers();
      users.sort((a, b) => a.name.compareTo(b.name));
      if (mounted) {
        setState(() {
          _users = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.show(context, 'Failed to load users', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(
        title: AppStrings.chatList,
        showBackButton: true,
      ),
      body: _isLoading
          ? _buildShimmerGrid()
          : _users.isEmpty
              ? AppEmptyState(title: "No users found", icon: Icons.people)
              : _buildUserGrid(),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(AppSpacing.lg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 0.8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Column(
          children: [
            AppShimmerBox(
                width: 80, height: 80, borderRadius: BorderRadius.circular(40)),
            SizedBox(height: AppSpacing.sm),
            AppShimmerBox(width: 60, height: 16),
          ],
        );
      },
    );
  }

  Widget _buildUserGrid() {
    return AnimationLimiter(
      child: GridView.builder(
        padding: EdgeInsets.all(AppSpacing.sm),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.lg,
          mainAxisSpacing: AppSpacing.lg,
          childAspectRatio: 0.8,
        ),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          final imageUrl = SupabaseService.getProfilePictureUrl(
              user.id); // Cache buster? Not critical here or use global

          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: AppAnimations.slow, // or Duration
            columnCount: 3,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              ChatMessagePage(user: user)) // passing UserModel
                      ),
                  onLongPress: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileLinkPage(userId: user.id))),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              width: 1),
                        ),
                        child: AppAvatar(imageUrl: imageUrl, radius: 40),
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        user.name,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
