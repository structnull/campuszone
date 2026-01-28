import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/models/models.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailPage extends StatelessWidget {
  final EventModel event;

  const EventDetailPage({super.key, required this.event});

  void _launchURL(BuildContext context) async {
    final urlString = event.registerUrl;
    if (urlString == null || urlString.isEmpty) {
      AppSnackbar.show(context, 'No registration link available.',
          isError: true);
      return;
    }

    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        AppSnackbar.show(context, 'Could not open the registration link.',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.id.isNotEmpty
        ? SupabaseService.storage
            .from('events')
            .getPublicUrl('events/${event.id}/events.jpg')
        : null;

    return AppScaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppAppBar(
          backgroundColor: Colors.transparent,
          showBackButton: true,
          iconTheme: IconThemeData(color: AppColors.black),
        ),
        body: Stack(
          children: [
            if (imageUrl != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.35,
                child: AppNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.zero,
                  enablePreview: true,
                ),
              ),

            // Content Sheet
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.3),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: Offset(0, -5),
                    )
                  ]),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: AppTextStyles.headlineMedium,
                    ),
                    SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(LineIcons.calendar,
                            size: 20, color: AppColors.textPrimary),
                        SizedBox(width: 6),
                        Text(event.date ?? 'Date',
                            style: AppTextStyles.bodyLarge),
                        SizedBox(width: 16),
                        Icon(LineIcons.clock,
                            size: 20, color: AppColors.textPrimary),
                        SizedBox(width: 6),
                        Text(event.time ?? 'Time',
                            style: AppTextStyles.bodyLarge),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (event.location != null)
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Icon(LineIcons.mapMarker,
                                size: 20, color: AppColors.textPrimary),
                            SizedBox(width: 6),
                            Expanded(
                                child: Text(event.location!,
                                    style: AppTextStyles.bodyLarge)),
                          ],
                        ),
                      ),
                    if (event.organizers.isNotEmpty)
                      _buildSection("Organizers", event.organizers),
                    if (event.tags.isNotEmpty)
                      _buildSection("Tags", event.tags),
                    AppCard(
                      backgroundColor: AppColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("About this event",
                              style: AppTextStyles.titleLarge),
                          SizedBox(height: 12),
                          Text(
                            event.description ?? "No description available.",
                            style: AppTextStyles.bodyMedium,
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: "Register for this event",
                        onPressed: () => _launchURL(context),
                        backgroundColor: AppColors.black,
                        textColor: AppColors.white,
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ));
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((e) => AppTag(
                    label: e,
                    backgroundColor: AppColors.black,
                    textColor: AppColors.white,
                  ))
              .toList(),
        ),
        SizedBox(height: 16),
      ],
    );
  }
}
