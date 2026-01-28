import 'dart:io';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerPage extends StatefulWidget {
  final Uri pdfUrl;
  final String filePath; // Path in Supabase storage
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.filePath,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  Future<void> _savePdf() async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }

        if (!status.isGranted) {
          var oldStatus = await Permission.storage.status;
          if (!oldStatus.isGranted) {
            oldStatus = await Permission.storage.request();
          }
          if (!oldStatus.isGranted) {
            if (mounted) {
              AppSnackbar.show(context, 'Storage permission required',
                  isError: true);
            }
            return;
          }
        }
      }

      if (!mounted) return;
      await _downloadAndSaveFile();
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Error checking permissions: $e',
            isError: true);
      }
    }
  }

  Future<void> _downloadAndSaveFile() async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;

      if (!mounted) return;
      AppSnackbar.show(context, 'Downloading...');

      final response =
          await SupabaseService.storage.from('notes').download(widget.filePath);

      final sanitizedTitle =
          widget.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final localFilePath = '$selectedDirectory/$sanitizedTitle.pdf';
      final file = File(localFilePath);
      await file.writeAsBytes(response);

      if (mounted) {
        AppSnackbar.show(context, 'Saved to $localFilePath');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Error saving file: $e', isError: true);
      }
    }
  }

  Future<void> _openExternal() async {
    try {
      if (await canLaunchUrl(widget.pdfUrl)) {
        await launchUrl(widget.pdfUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Could not open PDF', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppAppBar(
        title: 'PDF Viewer',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.download, color: AppColors.black),
            onPressed: _savePdf,
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.picture_as_pdf,
                  size: 80, color: AppColors.textSecondary),
              SizedBox(height: AppSpacing.lg),
              Text(widget.title,
                  style: AppTextStyles.headlineSmall,
                  textAlign: TextAlign.center),
              SizedBox(height: AppSpacing.xl),
              AppButton(
                text: 'Open in External Viewer',
                onPressed: _openExternal,
                icon: Icons.open_in_new,
              )
            ],
          ),
        ),
      ),
    );
  }
}
