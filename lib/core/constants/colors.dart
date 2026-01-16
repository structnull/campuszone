import 'package:flutter/material.dart';

abstract class AppColors {
  // Primary
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color primary = Color(0xFF252525);
  static const Color primaryDark = Color(0xFF121212);
  static const Color primaryLight = Color(0xFF242424);

  // Background
  static const Color scaffoldBackground = Color(0xFFEEE9E3);
  static const Color cardBackground = Colors.white;
  static const Color cardColor = cardBackground;
  static const Color cardDark = Colors.black;
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  // Text
  static const Color textPrimary = Color(0xFF252525);
  static const Color textSecondary = Color(0xFF7C7C7C);
  static const Color textLight = Color(0xFFDDDDDD);
  static const Color textWhite = Colors.white;
  static const Color textHint = Color(0xFF9E9E9E);

  // Status
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF2196F3);
  static const Color redAccent = Colors.redAccent;

  // Shimmer
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Navigation
  static const Color navUnselected = Colors.black;
  static const Color navSelected = Colors.white;
  static const Color tabBackground = Colors.black;

  // Gradient
  static const Color transparentWhite = Color.fromARGB(0, 255, 255, 255);
  static const Color semiTransparentWhite = Color.fromARGB(128, 255, 255, 255);
  static const Color opaqueWhite = Color.fromARGB(204, 255, 255, 255);

  // Border
  static const Color border = Color(0xFF252525);
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color shadow = Colors.black12;
  static const Color surface = cardBackground;
}
