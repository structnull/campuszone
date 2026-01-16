import 'package:campuszone/auth/auth.dart';
import 'package:campuszone/core/core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Application entry point
///
/// Initializes Supabase and runs the app with centralized theme
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // TODO: For production, use platform-specific secure storage instead
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.get('SUPABASE_URL'),
    anonKey: dotenv.get('SUPABASE_ANON_KEY'),
  );

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemUiStyle);

  runApp(const CampusZoneApp());
}

/// Root application widget
///
/// Uses centralized [AppTheme] for consistent styling across the app
class CampusZoneApp extends StatelessWidget {
  const CampusZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appName,

      // Use centralized theme from core/constants/themes.dart
      theme: AppTheme.lightTheme,

      home: const AuthPage(),
    );
  }
}
