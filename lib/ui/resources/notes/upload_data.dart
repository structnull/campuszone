import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:pdfrx/pdfrx.dart'; // Import pdfrx for PDF rendering

class UploadDataPage extends StatefulWidget {
  const UploadDataPage({super.key});

  @override
  State<UploadDataPage> createState() => _UploadDataPageState();
}

class _UploadDataPageState extends State<UploadDataPage> {
  File? _pdfFile;
  PdfDocument? _pdfDocument; // To hold the loaded PDF document
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  TextStyle get _headingStyle => const TextStyle(
        fontFamily: 'Excalifont',
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  TextStyle get _labelStyle => const TextStyle(
        fontFamily: 'Excalifont',
        fontSize: 16,
      );

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _pdfDocument
        ?.dispose(); // Dispose of the PDF document when the widget is disposed
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
        final document = await PdfDocument.openFile(
            pickedFile.path); // Load the PDF document

        setState(() {
          _pdfFile = pickedFile;
          _pdfDocument = document;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking the PDF: $e');
    }
  }

  Future<void> _submitPost() async {
    if (_pdfFile == null ||
        _titleController.text.isEmpty ||
        _descController.text.isEmpty) {
      _showErrorDialog('Please provide a PDF, title, and description.');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showErrorDialog('You must be logged in to post.');
      return;
    }

    debugPrint('Logged-in user ID: ${user.id}'); // Debugging

    setState(() => _isLoading = true);
    if (!mounted) return;

    try {
      final String noteId = const Uuid().v4();
      final String filePath = '${user.id}/$noteId.pdf';

      // Upload the PDF file to Supabase storage
      await Supabase.instance.client.storage
          .from('notes')
          .upload(filePath, _pdfFile!);

      // Insert the note into the database
      await Supabase.instance.client.from('notes').insert({
        'note_id': noteId,
        'user_id': user.id, // Ensure this matches the logged-in user's ID
        'title': _titleController.text,
        'description': _descController.text,
        'file_path': filePath,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showErrorDialog('Error uploading post: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _removePdf() {
    setState(() {
      _pdfFile = null;
      _pdfDocument?.dispose(); // Dispose of the PDF document when removed
      _pdfDocument = null;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Upload PDF',
          style: _headingStyle.copyWith(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.white,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: _pdfDocument == null
                          ? AspectRatio(
                              aspectRatio: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey, width: 2),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.picture_as_pdf,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            )
                          : AspectRatio(
                              aspectRatio: 1,
                              child: FutureBuilder<PdfDocument>(
                                future: PdfDocument.openFile(_pdfFile!.path),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  } else if (snapshot.hasError) {
                                    return Center(
                                        child: Text(
                                            'Error loading PDF: ${snapshot.error}'));
                                  } else if (snapshot.hasData) {
                                    final document = snapshot.data!;
                                    return PdfPageView(
                                      document: document,
                                      pageNumber: 1,
                                    );
                                  } else {
                                    return const Center(
                                        child: Text('No preview available'));
                                  }
                                },
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _pickPdf,
                          child: const Text('Pick PDF'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: _removePdf,
                          child: const Text('Remove PDF'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Title',
                        style: _labelStyle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      maxLines: 1,
                      maxLength: 50,
                      decoration: InputDecoration(
                        hintText: 'Enter title...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Description',
                        style: _labelStyle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      maxLines: 6,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText: 'Write something about the note...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Limited to 500 characters',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withAlpha(50),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
