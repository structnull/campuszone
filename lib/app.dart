import 'package:campuszone/presentation/screens/auth/auth.dart';
import 'package:campuszone/core/core.dart';
import 'package:campuszone/routing/routing.dart';
import 'package:flutter/material.dart';

class CampusZoneApp extends StatelessWidget {
  const CampusZoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const AuthPage(),
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: AppRoutes.initial,
    );
  }
}
