import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

// ----------------- Notice Model -----------------
class Notice {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

// ----------------- Simple Date Formatter -----------------
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

// ----------------- Supabase Service -----------------
class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Fetch all notices from the 'notice' table
  Future<List<Notice>> getNotices() async {
    try {
      final response = await _client
          .from('notice')
          .select()
          .order('created_at', ascending: false);
      return response.map<Notice>((notice) => Notice.fromJson(notice)).toList();
    } catch (e) {
      debugPrint('Error fetching notices: $e');
      return [];
    }
  }

  // Subscribe to changes in the 'notice' table
  Stream<List<Notice>> subscribeToNotices() {
    return _client
        .from('notice')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map<List<Notice>>((notices) =>
            notices.map<Notice>((notice) => Notice.fromJson(notice)).toList());
  }
}

// ----------------- Shimmer Loading Widget -----------------
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              height: 150.0,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ----------------- Notice Card Widget -----------------
class NoticeCard extends StatefulWidget {
  final Notice notice;
  final int index;

  const NoticeCard({
    super.key,
    required this.notice,
    required this.index,
  });

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Staggered animation entry
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
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          onHover: (isHovering) {
            if (isHovering) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
          borderRadius: BorderRadius.circular(16.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withAlpha(25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey[800]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Date Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.notice.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        formatDate(widget.notice.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Description with expand/collapse
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: _isExpanded ? 500 : 60,
                    ),
                    child: Text(
                      widget.notice.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      overflow: _isExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      maxLines: _isExpanded ? null : 2,
                    ),
                  ),
                ),
                // Expand/Collapse Button
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      _isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
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

// ----------------- Notice Board Content Widget -----------------
// This widget is refactored to be used inside other screens (e.g., HomePage).
class NoticeBoardContent extends StatefulWidget {
  const NoticeBoardContent({super.key});

  @override
  State<NoticeBoardContent> createState() => _NoticeBoardContentState();
}

class _NoticeBoardContentState extends State<NoticeBoardContent>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabaseService = SupabaseService();
  List<Notice> _notices = [];
  bool _isLoading = true;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  late ScrollController _scrollController;
  late final StreamSubscription<List<Notice>> _noticeSubscription =
      _supabaseService.subscribeToNotices().listen((notices) {
    setState(() {
      _notices = notices;
    });
  });

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    );
    _loadNotices();
    _headerAnimationController.forward();
  }

  Future<void> _loadNotices() async {
    setState(() {
      _isLoading = true;
    });
    _notices = await _supabaseService.getNotices();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
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
    // Wrap content in a Column so that it can be embedded in a Card.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated Header
        FadeTransition(
          opacity: _headerAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.2),
              end: Offset.zero,
            ).animate(_headerAnimation),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Noticeboard',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                          color: Colors.white.withAlpha(50),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${_notices.length} Notice${_notices.length != 1 ? 's' : ''} Posted',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        // Notice List or Loading Shimmer
        Expanded(
          child: _isLoading
              ? const ShimmerLoading()
              : _notices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 48,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 16.0),
                          Text(
                            'No notices available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotices,
                      backgroundColor: Colors.grey[900],
                      color: Colors.white,
                      child: Scrollbar(
                        controller: _scrollController,
                        thickness: 6.0,
                        radius: const Radius.circular(3.0),
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _notices.length,
                          padding: const EdgeInsets.all(20.0),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return NoticeCard(
                              notice: _notices[index],
                              index: index,
                            );
                          },
                        ),
                      ),
                    ),
        ),
      ],
    );
  }
}
