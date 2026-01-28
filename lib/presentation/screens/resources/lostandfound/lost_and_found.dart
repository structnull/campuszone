import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:campuszone/presentation/screens/resources/lostandfound/upload_data.dart';
import 'package:campuszone/presentation/screens/resources/comments/comments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:line_icons/line_icons.dart';

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
                  padding: EdgeInsets.only(bottom: AppSpacing.snackbar),
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
                          duration: AppAnimations.slow,
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: LostFoundItemCard(
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
