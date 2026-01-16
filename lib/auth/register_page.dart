import 'package:campuszone/auth/name_page.dart';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _collegeIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _addUserToSupabase(String uid, String name) async {
    await SupabaseService.usersTable.insert({
      'id': uid,
      'name': name,
      'email': _emailController.text.trim().toLowerCase(),
      'collegeid': _collegeIdController.text.trim().toUpperCase(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _register() async {
    final name = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NamePage()),
    );

    if (name == null || name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AppStrings.nameRequired)));
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await SupabaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user == null) {
        throw AuthException(AppStrings.registrationFailed);
      }

      await _addUserToSupabase(response.user!.id, name);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.registrationSuccessful)));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Navbar()),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Icon(LineIcons.userAstronaut,
                        size: AppIconSize.heroLarge, color: AppColors.primary),
                  ),
                  SizedBox(height: AppSpacing.sectionLarge),
                  Text(AppStrings.registerTitle,
                      style: AppTextStyles.displayLarge
                          .copyWith(color: AppColors.textPrimary)),
                  SizedBox(height: AppSpacing.sm),
                  Text(AppStrings.registerSubtitle,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.sectionLarge),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: AppStrings.email,
                      border: OutlineInputBorder(
                          borderRadius: AppRadius.featureCardRadius),
                      prefixIcon: const Icon(LineIcons.user),
                    ),
                    validator: Validators.email,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _collegeIdController,
                    decoration: InputDecoration(
                      labelText: AppStrings.collegeId,
                      border: OutlineInputBorder(
                          borderRadius: AppRadius.featureCardRadius),
                      prefixIcon: const Icon(LineIcons.identificationBadge),
                    ),
                    validator:
                        Validators.requiredWith(AppStrings.enterCollegeId),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.password,
                      border: OutlineInputBorder(
                          borderRadius: AppRadius.featureCardRadius),
                      prefixIcon: const Icon(LineIcons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? LineIcons.eyeAlt
                              : LineIcons.eyeSlashAlt,
                          color: AppColors.primary,
                        ),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: Validators.password,
                  ),
                  SizedBox(height: AppSpacing.sectionLarge),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.fullRadius),
                      ),
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: AppColors.textWhite,
                              strokeWidth: AppDimensions.loaderStrokeWidth)
                          : Text(AppStrings.register,
                              style: AppTextStyles.buttonMedium
                                  .copyWith(color: AppColors.textWhite)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _collegeIdController.dispose();
    super.dispose();
  }
}
