import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class Notice {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  Notice(
      {required this.id,
      required this.title,
      required this.description,
      required this.createdAt});

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        createdAt: DateTime.parse(json['created_at']),
      );
}

String formatDate(DateTime dateTime) {
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final day = dateTime.day;
  final month = months[dateTime.month - 1];
  final year = dateTime.year;
  final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  return '$month $day, $year • $hour:$minute $period';
}

class NoticeService {
  Future<List<Notice>> getNotices() async {
    try {
      final response = await SupabaseService.client
          .from('notice')
          .select()
          .order('created_at', ascending: false);
      return response.map<Notice>((notice) => Notice.fromJson(notice)).toList();
    } catch (e) {
      AppLogger.error('Error fetching notices', e);
      return [];
    }
  }

  Stream<List<Notice>> subscribeToNotices() {
    return SupabaseService.client
        .from('notice')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map<List<Notice>>((notices) =>
            notices.map<Notice>((notice) => Notice.fromJson(notice)).toList());
  }
}

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: ListView.builder(
        itemCount: 5,
        padding: EdgeInsets.all(AppSpacing.lg),
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.lg),
          child: Container(
              height: 150.0,
              decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: AppRadius.inputRadius)),
        ),
      ),
    );
  }
}

class NoticeCard extends StatefulWidget {
  final Notice notice;
  final int index;
  const NoticeCard({super.key, required this.notice, required this.index});
  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: AppAnimations.normal);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
        CurvedAnimation(
            parent: _controller, curve: AppAnimations.defaultCurve));
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          Transform.scale(scale: _scaleAnimation.value, child: child),
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.lg),
        child: InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          onHover: (h) {
            h ? _controller.forward() : _controller.reverse();
          },
          borderRadius: AppRadius.inputRadius,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.defaultCurve,
            padding: EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: AppRadius.inputRadius,
              boxShadow: [
                BoxShadow(
                    color: AppColors.textWhite.withAlpha(25),
                    blurRadius: 10,
                    offset: Offset(0, 4))
              ],
              border: Border.all(color: AppColors.textSecondary, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Text(widget.notice.title,
                            style: AppTextStyles.headlineSmall
                                .copyWith(color: AppColors.textWhite),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1)),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                          color: AppColors.textWhite.withAlpha(40),
                          borderRadius: AppRadius.cardRadius),
                      child: Text(formatDate(widget.notice.createdAt),
                          style: AppTextStyles.labelSmall
                              .copyWith(color: AppColors.textLight)),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                AnimatedSize(
                  duration: AppAnimations.normal,
                  curve: AppAnimations.defaultCurve,
                  child: Container(
                    constraints:
                        BoxConstraints(maxHeight: _isExpanded ? 500 : 60),
                    child: Text(widget.notice.description,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.textLight, height: 1.5),
                        overflow: _isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        maxLines: _isExpanded ? null : 2),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textLight),
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoticeBoardContent extends StatefulWidget {
  const NoticeBoardContent({super.key});
  @override
  State<NoticeBoardContent> createState() => _NoticeBoardContentState();
}

class _NoticeBoardContentState extends State<NoticeBoardContent>
    with SingleTickerProviderStateMixin {
  final NoticeService _noticeService = NoticeService();
  List<Notice> _notices = [];
  bool _isLoading = true;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  late ScrollController _scrollController;
  late final StreamSubscription<List<Notice>> _noticeSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _headerAnimation = CurvedAnimation(
        parent: _headerAnimationController, curve: AppAnimations.defaultCurve);
    _noticeSubscription = _noticeService
        .subscribeToNotices()
        .listen((notices) => setState(() => _notices = notices));
    _loadNotices();
    _headerAnimationController.forward();
  }

  Future<void> _loadNotices() async {
    setState(() => _isLoading = true);
    _notices = await _noticeService.getNotices();
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _noticeSubscription.cancel();
    _headerAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FadeTransition(
          opacity: _headerAnimation,
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset(0, -0.2), end: Offset.zero)
                .animate(_headerAnimation),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Text('Noticeboard',
                          style: AppTextStyles.displayLarge
                              .copyWith(color: AppColors.textWhite))),
                  SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.xxs),
                      decoration: BoxDecoration(
                          color: AppColors.textWhite.withAlpha(30),
                          borderRadius: AppRadius.featureCardRadius,
                          border: Border.all(
                              color: AppColors.textWhite.withAlpha(50))),
                      child: Text(
                          '${_notices.length} Notice${_notices.length != 1 ? 's' : ''} Posted',
                          style: AppTextStyles.labelLarge
                              .copyWith(color: AppColors.textWhite)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        Expanded(
          child: _isLoading
              ? const ShimmerLoading()
              : _notices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: AppIconSize.avatar,
                              color: AppColors.textSecondary),
                          SizedBox(height: AppSpacing.lg),
                          Text('No notices available',
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotices,
                      backgroundColor: AppColors.primaryDark,
                      color: AppColors.textWhite,
                      child: Scrollbar(
                        controller: _scrollController,
                        thickness: 6.0,
                        radius: Radius.circular(3.0),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _notices.length,
                          padding: EdgeInsets.all(AppSpacing.xl),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) =>
                              NoticeCard(notice: _notices[index], index: index),
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
