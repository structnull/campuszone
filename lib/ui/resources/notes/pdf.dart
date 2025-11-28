import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerPage extends StatelessWidget {
  final Uri pdfUrl;
  final String filePath; // Path in Supabase storage
  final String title; // Title of the note

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.filePath,
    required this.title,
  });

  Future<void> _savePdf(BuildContext context) async {
    try {
      // Check and request permissions based on Android version
      if (Platform.isAndroid) {
        final hasPermission =
            await Permission.manageExternalStorage.isGranted ||
                await Permission.manageExternalStorage.request().isGranted;
        if (hasPermission) {
          // Permission granted, proceed to save the file
          if (context.mounted) {
            await _downloadAndSaveFile(context);
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Storage permission is required to save the file. Please enable it in app settings.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        // For non-Android platforms, proceed to save the file
        await _downloadAndSaveFile(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadAndSaveFile(BuildContext context) async {
    try {
      // Let the user pick a directory
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        // User canceled the picker
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No directory selected.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Download the PDF file from Supabase storage
      final response = await Supabase.instance.client.storage
          .from('notes') // Replace 'notes' with your Supabase bucket name
          .download(filePath);

      // Save the file in the selected directory with the title as the file name
      final sanitizedTitle =
          title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_'); // Sanitize the title
      final localFilePath = '$selectedDirectory/$sanitizedTitle.pdf';
      final file = File(localFilePath);
      await file.writeAsBytes(response);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to $localFilePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        titleTextStyle: TextStyle(
            fontFamily: 'PlayfairDisplay', color: Colors.black, fontSize: 32),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _savePdf(context),
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            if (await canLaunchUrl(pdfUrl)) {
              await launchUrl(pdfUrl, mode: LaunchMode.externalApplication);
            } else {
              throw 'Could not launch $pdfUrl';
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Open PDF in External Viewer'),
        ),
      ),
    );
  }
}
