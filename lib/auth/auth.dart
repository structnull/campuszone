import 'package:campuszone/auth/login_page.dart';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/pages/navbar.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<AuthState>(
        stream: SupabaseService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            final session = snapshot.data?.session;
            if (session != null) {
              return Navbar();
            } else {
              return LoginPage();
            }
          }
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }
}
