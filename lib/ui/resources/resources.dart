import 'package:campuszone/custom/custom_divider.dart';
import 'package:campuszone/ui/resources/lostandfound/lost_and_found.dart';
import 'package:campuszone/ui/resources/notes/notes.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});
  Future<List<Map<String, dynamic>>> _fetchLinks() async {
    try {
      final List<dynamic> response = await Supabase.instance.client
          .from('useful_links')
          .select('name, link');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch links: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchLinks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading links'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No links found'));
                  }

                  final linksData = snapshot.data!;
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeaderSection(),

                            _buildLostAndFoundCard(context),

                            _buildNotesCard(context),

                            const SizedBox(height: 16),

                            _buildUsefulLinksHeader(),

                            ..._buildUsefulLinks(context, linksData),

                            const SizedBox(
                                height: 150), // Extra space to avoid navbar
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              'Resources',
              style: TextStyle(
                fontSize: 48.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Excalifont',
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: SquigglyDivider(
            color: Colors.black,
            width: 200,
            height: 50,
          ),
        ),
      ],
    );
  }

  Widget _buildLostAndFoundCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LostAndFoundPage()),
        );
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.black,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Lost and Found Section',
              style: const TextStyle(
                fontSize: 32.0,
                fontFamily: 'Excalifont',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotesPage()),
        );
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.black,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              'Notes Section',
              style: const TextStyle(
                fontSize: 32.0,
                fontFamily: 'Excalifont',
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsefulLinksHeader() {
    return Column(
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              'Useful Links',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'Excalifont',
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: SquigglyDivider(
            color: Colors.black,
            width: 200,
            height: 50,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildUsefulLinks(
      BuildContext context, List<Map<String, dynamic>> linksData) {
    return linksData.map((data) {
      return GestureDetector(
        onTap: () => _openLink(context, data['link'] as String),
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.black,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Text(
                      data['name'] as String,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontFamily: 'Excalifont',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Icon(
                  LineIcons.alternateExternalLink,
                  color: Colors.white,
                  size: 28.0,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }
}
