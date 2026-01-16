import 'package:campuszone/core/core.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class ForgotPassPage extends StatefulWidget {
  const ForgotPassPage({super.key});

  @override
  State<ForgotPassPage> createState() => _ForgotPassPageState();
}

class _ForgotPassPageState extends State<ForgotPassPage> {
  final _emailController = TextEditingController();

  Future<void> _passreset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppStrings.enterEmail)));
      return;
    }

    try {
      await SupabaseService.resetPassword(email);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Success', style: AppTextStyles.headlineSmall),
          content: Text(AppStrings.passwordResetSent,
              style: AppTextStyles.bodyMedium),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(AppStrings.ok),
            ),
          ],
        ),
      );
    } catch (e) {
      AppLogger.error('Password reset error', e);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.error, style: AppTextStyles.headlineSmall),
            content: Text(AppStrings.somethingWentWrong,
                style: AppTextStyles.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppStrings.ok),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: AppElevation.none,
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.huge),
              child: Text(AppStrings.forgotPassword,
                  style: AppTextStyles.displaySmall
                      .copyWith(color: AppColors.textPrimary)),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
                'Please enter the registered email associated with your account',
                style: AppTextStyles.bodyLarge
                    .copyWith(color: AppColors.textPrimary)),
            SizedBox(height: AppSpacing.huge),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: AppStrings.email,
                border: OutlineInputBorder(
                    borderRadius: AppRadius.featureCardRadius),
                prefixIcon: const Icon(LineIcons.user),
              ),
            ),
            SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeight,
              child: ElevatedButton(
                onPressed: _passreset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.featureCardRadius),
                ),
                child: Text(AppStrings.resetPassword,
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
