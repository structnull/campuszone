import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: AppElevation.none,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What is your name?',
                style: AppTextStyles.displayLarge
                    .copyWith(color: AppColors.textPrimary)),
            SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                    borderRadius: AppRadius.featureCardRadius),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.fullRadius),
                ),
                onPressed: () {
                  final name = _nameController.text.trim();
                  if (name.isNotEmpty) {
                    Navigator.pop(context, name);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please enter your name')));
                  }
                },
                child: Text('Continue',
                    style: AppTextStyles.buttonMedium
                        .copyWith(color: AppColors.textWhite)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
