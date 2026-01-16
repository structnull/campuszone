import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ensureAuthenticated();
  }

  Future<void> _ensureAuthenticated() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      _showErrorDialog('User is not authenticated. Please login.');
    }
  }

  Future<bool> _requestPermissions() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        if (!mounted) return false;
        _showErrorDialog(
          'Photo permission is permanently denied. Please enable it in app settings.',
        );
        await openAppSettings();
      }
      return false;
    }
    return true;
  }

  Future<void> _pickAndCropImage() async {
    if (!await _requestPermissions()) return;

    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (!mounted) return;
      if (pickedFile == null) return;

      // Ensure the file is a JPG image
      if (!pickedFile.path.toLowerCase().endsWith('.jpg') &&
          !pickedFile.path.toLowerCase().endsWith('.jpeg')) {
        if (!mounted) return;
        _showErrorDialog('Please select a JPG image.');
        return;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: 10,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.black,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            cropStyle: CropStyle.circle,
            statusBarColor: Colors.black,
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.square,
            // Adding SafeArea consideration
            dimmedLayerColor: Colors.black.withValues(alpha: .5),
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: true,
            cropStyle: CropStyle.circle,
            minimumAspectRatio: 1.0,
          ),
        ],
      );

      if (!mounted) return;
      if (croppedFile == null) return;

      final imageFile = File(croppedFile.path);
      if (mounted) {
        setState(() => _imageFile = imageFile);
      }

      await _uploadProfilePicture(imageFile);
    } catch (e) {
      if (mounted) _showErrorDialog('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadProfilePicture(File imageFile) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      _showErrorDialog('User is not authenticated. Please login.');
      return;
    }

    final fileName = '${user.id}/profile_picture.jpg';

    try {
      await supabase.storage.from('profilepic').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture updated successfully.')),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showErrorDialog('Error uploading profile picture: $e');
    }
  }

  Future<void> _removeProfilePicture() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (!mounted) return;
      _showErrorDialog('User is not authenticated. Please login.');
      return;
    }

    final fileName = '${user.id}/profile_picture.jpg';

    try {
      await supabase.storage.from('profilepic').remove([fileName]);
      if (!mounted) return;
      setState(() => _imageFile = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile picture removed successfully.')),
      );
    } catch (e) {
      if (mounted) _showErrorDialog('Error removing profile picture: $e');
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    // Capture the current context before any potential async gap.
    final currentContext = context;
    showDialog(
      context: currentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(currentContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      textStyle: const TextStyle(fontSize: 24, fontFamily: 'PlayfairDisplay'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    );
  }

  ButtonStyle _buttonStylered() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      textStyle: const TextStyle(fontSize: 24, fontFamily: 'PlayfairDisplay'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      backgroundColor: Colors.redAccent,
      foregroundColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Select a Profile Picture',
                      style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PlayfairDisplay'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: GestureDetector(
                        onTap: _pickAndCropImage,
                        child: CircleAvatar(
                          radius: 120,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : null,
                          child: _imageFile == null
                              ? const Icon(Icons.camera_alt,
                                  size: 50, color: Colors.white)
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: _buttonStyle(),
                      onPressed: _pickAndCropImage,
                      child: const Text('Retake Profile Picture'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: _buttonStylered(),
                      onPressed: () async {
                        await _removeProfilePicture();
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, true);
                      },
                      child: const Text('Remove Profile Picture'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
