import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:campuszone/presentation/screens/community/events/eventdetails.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final EventRepository _repository = EventRepository();
  List<EventModel> events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      final data = await _repository.getAllEvents();
      if (mounted) {
        setState(() {
          events = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.scaffoldBackground,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                children: [
                  Text("Upcoming Events", style: AppTextStyles.headlineMedium),
                  SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.snackbar,
                        vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                    child: Text(events.length.toString(),
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.white)),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.md),
            _isLoading
                ? Center(child: AppLoader())
                : events.isEmpty
                    ? AppEmptyState(
                        icon: LineIcons.cryingFace, title: "No events for now")
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: events.length,
                        itemBuilder: (context, index) =>
                            _EventCard(event: events[index]),
                      ),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final imageUrl = SupabaseService.storage
        .from('events')
        .getPublicUrl('events/${event.id}/events.jpg');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EventDetailPage(event: event)),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.black, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(13),
              spreadRadius: 1,
              blurRadius: AppSpacing.sm,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.organizers.isNotEmpty)
              Padding(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: event.organizers
                        .map((organizer) => AppTag(
                              label: organizer,
                              backgroundColor: AppColors.cardDark,
                              textColor: AppColors.textPrimary,
                              borderRadius: AppRadius.full,
                              padding: AppSpacing.chipPadding,
                            ))
                        .toList(),
                  )),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(event.title, style: AppTextStyles.headlineSmall),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text("${event.date ?? ''} · ${event.time ?? ''}",
                  style: AppTextStyles.bodyMediumBold),
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Icon(Icons.location_on,
                      size: AppIconSize.xs, color: AppColors.textSecondary),
                  SizedBox(width: AppSpacing.xxs),
                  Text(event.location ?? '', style: AppTextStyles.caption),
                ],
              ),
            ),
            if (event.tags.isNotEmpty)
              Padding(
                padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: event.tags
                      .map((tag) => AppTag(
                            label: tag,
                            backgroundColor: AppColors.cardDark,
                            textColor: AppColors.textWhite,
                            borderRadius: AppRadius.md,
                          ))
                      .toList(),
                ),
              ),
            SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(AppRadius.xl)),
              child: AppNetworkImage(
                imageUrl: imageUrl,
                height: AppDimensions.eventImageHeight,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
