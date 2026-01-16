import 'package:campuszone/presentation/screens/auth/auth.dart';
import 'package:campuszone/presentation/screens/auth/forgot_pass.dart';
import 'package:campuszone/presentation/screens/auth/login_page.dart';
import 'package:campuszone/presentation/screens/auth/register_page.dart';
import 'package:campuszone/presentation/screens/chat/chat_list.dart';
import 'package:campuszone/presentation/screens/main/navbar.dart';
import 'package:campuszone/routing/app_routes.dart';
import 'package:campuszone/presentation/screens/community/community.dart';
import 'package:campuszone/presentation/screens/home/home.dart';
import 'package:campuszone/presentation/screens/profile/profile.dart';
import 'package:campuszone/presentation/screens/profile/editprofile/edit_profile.dart';
import 'package:campuszone/presentation/screens/resources/resources.dart';
import 'package:campuszone/presentation/screens/resources/lostandfound/lost_and_found.dart';
import 'package:campuszone/presentation/screens/resources/notes/notes.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.initial:
      case AppRoutes.auth:
        return _buildRoute(const AuthPage(), settings);
      case AppRoutes.login:
        return _buildRoute(const LoginPage(), settings);
      case AppRoutes.register:
        return _buildRoute(const RegisterPage(), settings);
      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPassPage(), settings);
      case AppRoutes.navbar:
        return _buildRoute(const Navbar(), settings);
      case AppRoutes.home:
        return _buildRoute(const HomePage(), settings);
      case AppRoutes.chat:
        return _buildRoute(const ChatPageList(), settings);
      case AppRoutes.community:
        return _buildRoute(const CommunityPage(), settings);
      case AppRoutes.resources:
        return _buildRoute(const ResourcesPage(), settings);
      case AppRoutes.lostAndFound:
        return _buildRoute(const LostAndFoundPage(), settings);
      case AppRoutes.notes:
        return _buildRoute(const NotesPage(), settings);
      case AppRoutes.profile:
        return _buildRoute(const ProfilePage(), settings);
      case AppRoutes.editProfile:
        return _buildRoute(const EditProfilePage(), settings);
      default:
        return _buildRoute(
          Scaffold(
              body: Center(child: Text('Route not found: ${settings.name}'))),
          settings,
        );
    }
  }

  static MaterialPageRoute<T> _buildRoute<T>(
      Widget page, RouteSettings settings) {
    return MaterialPageRoute<T>(builder: (_) => page, settings: settings);
  }

  static PageRouteBuilder<T> buildSlideRoute<T>(Widget page,
      {Duration? duration}) {
    return PageRouteBuilder<T>(
      transitionDuration: duration ?? const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  static PageRouteBuilder<T> buildFadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
