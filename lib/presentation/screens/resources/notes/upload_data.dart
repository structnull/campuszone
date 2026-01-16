import 'dart:io';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

class UploadNotePage extends StatefulWidget {
  const UploadNotePage({super.key});

  @override
  State<UploadNotePage> createState() => _UploadNotePageState();
}

class _UploadNotePageState extends State<UploadNotePage> {
  final NoteRepository _repository = NoteRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _pdfFile;
  PdfDocument? _pdfDocument;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pdfDocument?.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        final document = await PdfDocument.openFile(pickedFile.path);

        setState(() {
          _pdfFile = pickedFile;
          _pdfDocument = document;
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Error picking PDF: $e', isError: true);
      }
    }
  }

  void _removePdf() {
    setState(() {
      _pdfFile = null;
      _pdfDocument?.dispose();
      _pdfDocument = null;
    });
  }

  Future<void> _submitPost() async {
    if (_pdfFile == null ||
        _titleController.text.isEmpty ||
        _descController.text.isEmpty) {
      AppSnackbar.show(context, 'Please provide a PDF, title, and description.',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _repository.uploadNote(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        file: _pdfFile!,
      );
      if (mounted) {
        AppSnackbar.show(context, 'Note uploaded successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Failed to upload note', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(title: 'Upload Note', showBackButton: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
              child: Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                        color: AppColors.surfaceGrey,
                        borderRadius: AppRadius.cardRadius,
                        border: Border.all(color: AppColors.borderLight)),
                    child: _pdfDocument == null
                        ? Center(
                            child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.picture_as_pdf,
                                  size: 64, color: AppColors.textSecondary),
                              SizedBox(height: AppSpacing.md),
                              Text("No PDF Selected",
                                  style: AppTextStyles.bodyMedium)
                            ],
                          ))
                        : PdfPageView(
                            document: _pdfDocument!,
                            pageNumber: 1,
                          ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Pick PDF',
                          onPressed: _pickPdf,
                          isOutlined: true,
                        ),
                      ),
                      if (_pdfFile != null) ...[
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppButton(
                            text: 'Remove',
                            onPressed: _removePdf,
                            backgroundColor: AppColors.error,
                            textColor: AppColors.white,
                          ),
                        ),
                      ]
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _titleController,
              labelText: 'Title',
              hintText: 'Enter title...',
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _descController,
              labelText: 'Description',
              hintText: 'Write something about the note...',
              maxLines: 4,
            ),
            SizedBox(height: AppSpacing.xl),
            _isLoading
                ? Center(child: AppLoader())
                : AppButton(
                    text: 'Submit Note',
                    onPressed: _submitPost,
                  )
          ],
        ),
      ),
    );
  }
}
