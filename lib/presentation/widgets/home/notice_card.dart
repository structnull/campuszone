import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

/// A model class for notice data used by NoticeCard.
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

  factory Notice.fromJson(Map<String, dynamic> json) => Notice(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        createdAt: DateTime.parse(json['created_at']),
      );
}

/// Formats a DateTime to a human-readable string.
String formatNoticeDate(DateTime dateTime) {
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

/// An expandable notice card widget with animation effects.
///
/// Used in the Notice Board page to display individual notices
/// with expand/collapse functionality.
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
                      child: Text(formatNoticeDate(widget.notice.createdAt),
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
