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
                        itemBuilder: (context, index) => EventCard(
                          event: events[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    EventDetailPage(event: events[index])),
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
