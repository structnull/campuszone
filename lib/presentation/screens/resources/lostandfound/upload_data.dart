import 'dart:io';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/data/repositories/repositories.dart';
import 'package:campuszone/presentation/presentation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;

class UploadLostFoundPage extends StatefulWidget {
  const UploadLostFoundPage({super.key});

  @override
  State<UploadLostFoundPage> createState() => _UploadLostFoundPageState();
}

class _UploadLostFoundPageState extends State<UploadLostFoundPage> {
  final LostAndFoundRepository _repository = LostAndFoundRepository();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _imageFile;
  double? _imageAspectRatio;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCropImage() async {
    final status = await Permission.photos.request();
    if (!status.isGranted && !status.isLimited) {
      if (status.isPermanentlyDenied) {
        if (mounted) {
          AppSnackbar.show(context, 'Photo permission needed', isError: true);
        }
        await openAppSettings();
      }
      return;
    }

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressQuality: 50,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.black,
            toolbarWidgetColor: AppColors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
      );

      if (croppedFile == null) return;

      final file = File(croppedFile.path);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        setState(() {
          _imageFile = file;
          _imageAspectRatio = image.width / image.height.toDouble();
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Error picking image: $e', isError: true);
      }
    }
  }

  void _removePicture() {
    setState(() {
      _imageFile = null;
      _imageAspectRatio = null;
    });
  }

  Future<void> _submitPost() async {
    if (_imageFile == null ||
        _titleController.text.isEmpty ||
        _descController.text.isEmpty) {
      AppSnackbar.show(
          context, 'Please provide an image, title, and description.',
          isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _repository.createItem(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        imageFile: _imageFile!,
      );
      if (mounted) {
        AppSnackbar.show(context, 'Item posted successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(context, 'Failed to post item', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppAppBar(title: 'Upload Item', showBackButton: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppCard(
                child: Column(
              children: [
                Container(
                  height: _imageAspectRatio != null ? null : 300,
                  constraints: BoxConstraints(maxHeight: 400),
                  decoration: BoxDecoration(
                      color: AppColors.surfaceGrey,
                      borderRadius: AppRadius.cardRadius,
                      border: Border.all(color: AppColors.borderLight)),
                  child: _imageFile == null
                      ? Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 64, color: AppColors.textSecondary),
                            SizedBox(height: AppSpacing.md),
                            Text("No Image Selected",
                                style: AppTextStyles.bodyMedium)
                          ],
                        ))
                      : ClipRRect(
                          borderRadius: AppRadius.cardRadius,
                          child: AspectRatio(
                            aspectRatio: _imageAspectRatio ?? 1,
                            child: Image.file(_imageFile!, fit: BoxFit.contain),
                          ),
                        ),
                ),
                SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: _imageFile == null ? 'Pick Image' : 'Change',
                        onPressed: _pickAndCropImage,
                        isOutlined: true,
                      ),
                    ),
                    if (_imageFile != null) ...[
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppButton(
                          text: 'Remove',
                          onPressed: _removePicture,
                          backgroundColor: AppColors.error,
                          textColor: AppColors.white,
                        ),
                      ),
                    ]
                  ],
                )
              ],
            )),
            SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _titleController,
              labelText: 'Title',
              hintText: 'Enter title (e.g. Lost Keys)',
            ),
            SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: _descController,
              labelText: 'Description',
              hintText: 'Describe the item...',
              maxLines: 4,
            ),
            SizedBox(height: AppSpacing.xl),
            _isLoading
                ? Center(child: AppLoader())
                : AppButton(
                    text: 'Submit Post',
                    onPressed: _submitPost,
                  )
          ],
        ),
      ),
    );
  }
}
