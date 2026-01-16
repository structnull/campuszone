import 'package:campuszone/auth/forgot_pass.dart';
import 'package:campuszone/auth/register_page.dart';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureText = true;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.pageTransition,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.92, end: 1.0).animate(_controller);
    _controller.forward();
  }

  Future<String?> _getEmailFromCollegeId(String collegeId) async {
    final response = await SupabaseService.usersTable
        .select('email')
        .eq('collegeid', collegeId)
        .maybeSingle();
    return response?['email'];
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String input = _emailController.text.trim().toUpperCase();
      String? email = input;

      if (!input.contains('@')) {
        email = await _getEmailFromCollegeId(input);
        if (email == null) {
          _showSnackBar(AppStrings.noCollegeIdFound);
          setState(() => _isLoading = false);
          return;
        }
      }

      final res = await SupabaseService.signInWithPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      if (res.session != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => Navbar()));
      } else {
        _showSnackBar(AppStrings.loginFailed);
      }
    } catch (e) {
      _showSnackBar(AppStrings.somethingWentWrong);
      AppLogger.error('Login error', e);
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScaleTransition(
          scale: _animation,
          child: SingleChildScrollView(
            padding: AppSpacing.authPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset(AppAssets.appIcon, width: 62, height: 62),
                        SizedBox(height: AppSpacing.xxs),
                        Text(AppStrings.appName,
                            style: AppTextStyles.titleMedium
                                .copyWith(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.hero),
                  Text(AppStrings.welcomeBack,
                      style: AppTextStyles.displayMedium
                          .copyWith(color: AppColors.textPrimary)),
                  Text(AppStrings.signInToContinue,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.textPrimary)),
                  SizedBox(height: AppSpacing.sectionLarge),
                  Text(AppStrings.emailOrCollegeId,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.xxs),
                  Container(
                    height: AppDimensions.inputHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: AppRadius.inputRadius,
                    ),
                    padding: AppSpacing.inputPadding,
                    child: Row(
                      children: [
                        Icon(LineIcons.userCircle, size: AppIconSize.md),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            validator: Validators.required,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  Text(AppStrings.password,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.textSecondary)),
                  SizedBox(height: AppSpacing.xxs),
                  Container(
                    height: AppDimensions.inputHeight,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: AppRadius.inputRadius,
                    ),
                    padding: AppSpacing.inputPadding,
                    child: Row(
                      children: [
                        Icon(LineIcons.lock, size: AppIconSize.md),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration:
                                const InputDecoration(border: InputBorder.none),
                            validator: Validators.required,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                              _obscureText ? LineIcons.eye : LineIcons.eyeSlash,
                              size: AppIconSize.sm),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ForgotPassPage())),
                      child: Text(AppStrings.forgotPassword,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.textSecondary)),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: AppDimensions.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.buttonRadius),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              strokeWidth: AppDimensions.loaderStrokeWidth,
                              color: AppColors.textWhite)
                          : Text(AppStrings.signIn,
                              style: AppTextStyles.buttonLarge
                                  .copyWith(color: AppColors.textLight)),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  Center(
                      child: Text(AppStrings.dontHaveAccount,
                          style: AppTextStyles.bodyMedium)),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterPage())),
                      child: Text(AppStrings.signUp,
                          style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold)),
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
    _controller.dispose();
    super.dispose();
  }
}
