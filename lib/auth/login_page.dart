import 'package:campuszone/auth/forgot_pass.dart';
import 'package:campuszone/auth/register_page.dart';
import 'package:campuszone/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.92, end: 1.0).animate(_controller);
    _controller.forward();
  }

  Future<String?> _getEmailFromCollegeId(String collegeId) async {
    final response = await Supabase.instance.client
        .from('users')
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
          _showSnackBar("No matching College ID found.");
          setState(() => _isLoading = false);
          return;
        }
      }

      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: _passwordController.text.trim(),
      );

      if (res.session != null) {
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => Navbar()));
      } else {
        _showSnackBar("Login failed. Please try again.");
      }
    } catch (e) {
      _showSnackBar("Error: $e");
    }

    setState(() => _isLoading = false);
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScaleTransition(
          scale: _animation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// --- Top Logo ---
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/icon/icon.png',
                          width: 62,
                          height: 62,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "CampusZone",
                          style: TextStyle(
                            fontSize: 17,
                            color: const Color(0xFF252525),
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 80),

                  Text(
                    "Welcome Back :)",
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'PlayfairDisplay',
                      color: const Color(0xFF252525),
                    ),
                  ),

                  Text(
                    "Please Sign in to continue",
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF252525),
                    ),
                  ),

                  const SizedBox(height: 60),

                  Text(
                    "Email or College ID",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF252525)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        const Icon(LineIcons.userCircle, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "",
                              border: InputBorder.none,
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Required" : null,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF252525)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        const Icon(LineIcons.lock, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "",
                              hintStyle: TextStyle(fontSize: 14),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? "Required" : null,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _obscureText ? LineIcons.eye : LineIcons.eyeSlash,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPassPage()),
                      ),
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF7C7C7C),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF242424),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            )
                          : Text(
                              "Sign In",
                              style: TextStyle(
                                color: const Color(0xFFDDDDDD),
                                fontSize: 20,
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),
                  Center(
                      child: Text(("Don’t have an account?"),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14))),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: Text(
                        "Sign Up",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
