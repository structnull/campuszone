import 'package:campuszone/chat/chatmsgpage.dart';
import 'package:campuszone/pages/profilelink.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ChatPageList displays a grid of user profile bubbles.
class ChatPageList extends StatefulWidget {
  const ChatPageList({super.key});

  @override
  @override
  // ignore: library_private_types_in_public_api
  _ChatPageListState createState() => _ChatPageListState();
}

class _ChatPageListState extends State<ChatPageList> {
  List<dynamic> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  /// Fetches all users from the 'users' table in Supabase excluding the current user.
  Future<void> fetchUsers() async {
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('users')
          .select()
          .neq('id', currentUserId);

      // Convert the data to a list and sort alphabetically by the 'name' field.
      final List<dynamic> fetchedUsers = data as List<dynamic>;
      fetchedUsers
          .sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      if (!mounted) return;
      setState(() {
        users = fetchedUsers;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('Error fetching users: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Chat List'),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 32,
        ),
      ),
      body: isLoading ? buildShimmerGrid() : buildUserGrid(),
    );
  }

  /// Build a shimmer placeholder grid while loading data.
  Widget buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust the number of columns as needed
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 16,
                color: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build the grid of user profile bubbles with names.
  Widget buildUserGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust the number of columns as needed
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        // Check if profile_pic_path exists and is not null, else use the placeholder.
        final String? profilePicPath = user['profile_pic_path'] as String?;
        final String imageUrl =
            (profilePicPath != null && profilePicPath.isNotEmpty)
                ? Supabase.instance.client.storage
                    .from('profilepic')
                    .getPublicUrl(profilePicPath)
                : ''; // Empty string for fallback to AssetImage

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatMessagePage(user: user),
              ),
            );
          },
          onLongPress: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileLinkPage(userId: user['id']),
              ),
            );
          },
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/profile.png',
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/profile.png',
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                user['name'] ?? 'No Name',
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
