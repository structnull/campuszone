import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/globals.dart' as globals;
import 'package:campuszone/presentation/presentation.dart';
import 'package:campuszone/presentation/screens/resources/lostandfound/upload_data.dart';
import 'package:campuszone/presentation/screens/resources/comments/comments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class LostAndFoundPage extends StatefulWidget {
  const LostAndFoundPage({super.key});

  @override
  State<LostAndFoundPage> createState() => _LostAndFoundPageState();
}

class _LostAndFoundPageState extends State<LostAndFoundPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  List<LostAndFoundModel> _items = [];
  final LostAndFoundRepository _repository = LostAndFoundRepository();
  final String? currentUserId = SupabaseService.currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final items = await _repository.getAllItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Using AppSnackbar is better for non-blocking error display
        AppSnackbar.show(context, 'Failed to load items', isError: true);
      }
    }
  }

  Future<void> _deleteItem(LostAndFoundModel item) async {
    final confirm = await AppDialog.showConfirmation(
      context: context,
      title: 'Confirm Delete',
      message: 'Are you sure you want to delete this item?',
      confirmText: 'Delete',
      isDanger: true,
    );
    if (!mounted) return;
    if (confirm != true) return;

    try {
      AppSnackbar.show(context, 'Deleting item...');
      await _repository.deleteItem(item.id);
      if (mounted) {
        AppSnackbar.show(context, 'Item deleted successfully');
        _fetchItems();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Failed to delete item', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppAppBar(title: 'Lost & Found', showBackButton: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UploadLostFoundPage()),
          );
          if (result == true) _fetchItems();
        },
        backgroundColor: AppColors.black,
        child: Icon(LineIcons.plus, color: AppColors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchItems,
        color: AppColors.primary,
        child: _isLoading
            ? ListView.builder(
                padding: EdgeInsets.all(AppSpacing.md),
                itemCount: 5,
                itemBuilder: (_, __) => Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: AppShimmerBox(width: double.infinity, height: 150),
                ),
              )
            : _items.isEmpty
                ? AppEmptyState(icon: LineIcons.box, title: 'No items found')
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                          AppSpacing.md, AppSpacing.md, AppSpacing.md, 80),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 500),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _ItemCard(
                                item: item,
                                isCurrentUser: item.userId == currentUserId,
                                onDelete: () => _deleteItem(item),
                                onComments: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CommentsPage(
                                      entityId: item.id,
                                      entityType: 'lostandfound',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final LostAndFoundModel item;
  final bool isCurrentUser;
  final VoidCallback onDelete;
  final VoidCallback onComments;

  const _ItemCard({
    required this.item,
    required this.isCurrentUser,
    required this.onDelete,
    required this.onComments,
  });

  @override
  Widget build(BuildContext context) {
    String? imageUrl;
    if (item.imagePath.isNotEmpty) {
      imageUrl = SupabaseService.storage
          .from('lostandfound')
          .getPublicUrl(item.imagePath);
    }

    final profileUrl = SupabaseService.getProfilePictureUrl(item.userId,
        cacheBuster: globals.globalCacheBuster.value);

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                AppAvatar(imageUrl: profileUrl, radius: 20),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.authorName ?? 'Unknown User',
                          style: AppTextStyles.bodyLargeBold),
                      Text(timeago.format(item.createdAt),
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
                if (isCurrentUser)
                  IconButton(
                      icon: Icon(LineIcons.trash, color: AppColors.error),
                      onPressed: onDelete),
              ],
            ),
          ),
          if (imageUrl != null)
            AppNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              enablePreview: true,
              height: 300,
            ),
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.headlineSmall),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(item.description, style: AppTextStyles.bodyMedium),
                ],
                SizedBox(height: AppSpacing.sm),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onComments,
                      icon: Icon(LineIcons.comment, size: 20),
                      label: Text('Comments'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
