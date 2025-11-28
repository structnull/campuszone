import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventDetailPage extends StatelessWidget {
  final Map<String, dynamic> event;

  const EventDetailPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Compute the image URL from Supabase storage using event id.
    final eventId = event['id']?.toString();
    final imageUrl = eventId != null
        ? Supabase.instance.client.storage
            .from('events')
            .getPublicUrl('events/$eventId/events.jpg')
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Hero image with shimmer effect
          if (imageUrl != null)
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.3,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.3,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),

          // SafeArea to encapsulate the notch
          SafeArea(
            child: Stack(
              children: [
                // Floating back button
                Positioned(
                  top: 16,
                  left: 16,
                  child: CircleAvatar(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.only(top: 250.0), // Adjust for image
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .4),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            event['title'] ?? 'Event Name',
                            style: textTheme.headlineMedium?.copyWith(
                              fontFamily: 'Excalifont',
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Date, time, and location row with icons
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 20, color: Colors.black),
                              const SizedBox(width: 6),
                              Text(
                                event['date'] ?? 'Date',
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time,
                                  size: 20, color: Colors.black),
                              const SizedBox(width: 6),
                              Text(
                                event['time'] ?? 'Time',
                                style: textTheme.bodyLarge,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (event['location'] != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on,
                                      size: 20, color: Colors.black),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      event['location'],
                                      style: textTheme.bodyLarge,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Organizers section
                          if (event['organizers'] != null &&
                              (event['organizers'] as List).isNotEmpty)
                            _buildTagSection(
                                'Organizers', event['organizers'], textTheme),

                          // Tags section
                          if (event['tags'] != null &&
                              (event['tags'] as List).isNotEmpty)
                            _buildTagSection('Tags', event['tags'], textTheme),

                          // Description section
                          Card(
                            color: Colors.grey[100],
                            elevation: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'About this event',
                                    style: textTheme.titleLarge?.copyWith(
                                      fontFamily: 'Excalifont',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    event['description'] ??
                                        'No description available.',
                                    style: textTheme.bodyLarge?.copyWith(
                                      height: 1.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Register button
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _launchURL(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                              child: const Text(
                                'Register for this event',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Excalifont',
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to launch URL safely
  void _launchURL(BuildContext context) async {
    final urlString = event['register_url'];
    if (urlString == null || urlString.isEmpty) {
      _showSnackbar(context, 'No registration link available.');
      return;
    }

    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        _showSnackbar(context, 'Could not open the registration link.');
      }
    }
  }

  // Helper method to show snackbar
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Helper method to build tag sections (Organizers, Tags)
  Widget _buildTagSection(
      String title, List<dynamic> items, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontFamily: 'Excalifont',
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: items
              .map((item) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
