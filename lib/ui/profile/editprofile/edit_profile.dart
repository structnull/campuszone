import 'package:campuszone/globals.dart';
import 'package:campuszone/ui/profile/editprofile/profilepic/profile_picture.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers for basic profile data.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _collegeIdController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // Controllers for social profiles.
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  final supabase = Supabase.instance.client;
  bool _isLoading = true; // For loading state

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch both basic profile data and socials.
  Future<void> _fetchUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      // Fetch from users table.
      final userResponse =
          await supabase.from('users').select().eq('id', user.id).maybeSingle();

      // Fetch socials from socials table.
      final socialsResponse = await supabase
          .from('socials')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      setState(() {
        // Update all controllers in one go.
        if (userResponse != null) {
          _nameController.text = userResponse['name'] ?? '';
          _emailController.text = userResponse['email'] ?? user.email ?? '';
          _collegeIdController.text = userResponse['collegeid'] ?? '';
          _bioController.text = userResponse['bio'] ?? '';
        }
        if (socialsResponse != null) {
          _linkedinController.text = socialsResponse['linkedin'] ?? '';
          _twitterController.text = socialsResponse['twitter'] ?? '';
          _instagramController.text = socialsResponse['instagram'] ?? '';
        }
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile data: $e')),
      );
    }
  }

  // Update both users and socials in Supabase using upsert.
  Future<void> _updateUserData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // Construct the profile picture path
      final profilePicPath = '${user.id}/profile_picture.jpg';

      // Upsert basic profile data in the users table
      await supabase.from('users').upsert({
        'id': user.id,
        'name': _nameController.text,
        'email': _emailController.text,
        'bio': _bioController.text,
        'collegeid': _collegeIdController.text,
        'profile_pic_path': profilePicPath,
      });

      // Upsert social media links in the socials table
      await supabase.from('socials').upsert({
        'id': user.id,
        'linkedin': _linkedinController.text,
        'twitter': _twitterController.text,
        'instagram': _instagramController.text,
      });

      // Update the global cache buster
      final newCacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
      globalCacheBuster.value = newCacheBuster;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      if (mounted) {
        Navigator.pop(context, {'updated': true});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  // Get profile picture URL with cache buster
  String _getProfilePicUrl() {
    final user = supabase.auth.currentUser;
    if (user == null) return 'assets/profile.png';
    String url = supabase.storage
        .from('profilepic')
        .getPublicUrl('${user.id}/profile_picture.jpg');
    final cacheBuster = globalCacheBuster.value;
    if (cacheBuster != null) {
      url = '$url?t=$cacheBuster';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Basic Info',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              // Navigate to ProfilePicture for updating
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfilePicture()),
                              );
                              if (result == true) {
                                final newCacheBuster = DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString();
                                globalCacheBuster.value = newCacheBuster;
                                setState(() {});
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.black, width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 80,
                                    backgroundColor: Colors.white10,
                                    backgroundImage:
                                        NetworkImage(_getProfilePicUrl()),
                                    onBackgroundImageError: (_, __) {},
                                  ),
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 5,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.black,
                                    child: Icon(
                                      LineIcons.camera,
                                      size: 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        buildTextField(
                            label: 'Name', controller: _nameController),
                        const SizedBox(height: 10),
                        buildTextField(
                            label: 'Email', controller: _emailController),
                        const SizedBox(height: 10),
                        buildTextField(
                          label: 'CollegeID',
                          controller: _collegeIdController,
                          readOnly: true,
                        ),
                        const SizedBox(height: 10),
                        buildTextField(
                          label: 'Bio',
                          controller: _bioController,
                          maxLines: 4,
                          charLimit: '${_bioController.text.length}/300',
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Limited to 300 characters',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Socials',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                          ),
                        ),
                        const Text(
                          'Add username of social profiles',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        buildTextField(
                            label: 'LinkedIn', controller: _linkedinController),
                        const SizedBox(height: 10),
                        buildTextField(
                            label: 'Twitter (X)',
                            controller: _twitterController),
                        const SizedBox(height: 10),
                        buildTextField(
                            label: 'Instagram',
                            controller: _instagramController),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: ElevatedButton(
                      onPressed: _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          fontFamily: 'PlayfairDisplay',
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    TextEditingController? controller,
    bool readOnly = false,
    int maxLines = 1,
    String charLimit = '',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          readOnly: readOnly,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            if (label == 'Bio') {
              setState(() {});
            }
          },
        ),
        if (charLimit.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              charLimit,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _collegeIdController.dispose();
    _bioController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    super.dispose();
  }
}
