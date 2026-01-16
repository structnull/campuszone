import 'package:flutter/material.dart';

/// Centralized color palette for the CampusZone app
///
/// Usage:
/// ```dart
/// Container(color: AppColors.primary)
/// Text('Hello', style: TextStyle(color: AppColors.textPrimary))
/// ```
abstract class AppColors {
  // ============================================
  // PRIMARY COLORS
  // ============================================

  /// Main brand color - dark charcoal
  static const Color primary = Color(0xFF252525);

  /// Darker variant for elevated surfaces
  static const Color primaryDark = Color(0xFF121212);

  /// Slightly lighter primary for buttons
  static const Color primaryLight = Color(0xFF242424);

  // ============================================
  // BACKGROUND COLORS
  // ============================================

  /// Main scaffold background - warm off-white
  static const Color scaffoldBackground = Color(0xFFEEE9E3);

  /// Card/container background
  static const Color cardBackground = Colors.white;

  /// Dark card background (for feature cards)
  static const Color cardDark = Colors.black;

  /// Grey background for lists
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  // ============================================
  // TEXT COLORS
  // ============================================

  /// Primary text color - dark
  static const Color textPrimary = Color(0xFF252525);

  /// Secondary text color - grey
  static const Color textSecondary = Color(0xFF7C7C7C);

  /// Light text for dark backgrounds
  static const Color textLight = Color(0xFFDDDDDD);

  /// White text
  static const Color textWhite = Colors.white;

  /// Hint/placeholder text
  static const Color textHint = Color(0xFF9E9E9E);

  // ============================================
  // ACCENT/STATUS COLORS
  // ============================================

  /// Success/confirmation green
  static const Color success = Color(0xFF4CAF50);

  /// Error/danger red
  static const Color error = Color(0xFFE53935);

  /// Warning/attention orange
  static const Color warning = Color(0xFFFFA726);

  /// Info blue
  static const Color info = Color(0xFF2196F3);

  /// Red accent for delete actions
  static const Color redAccent = Colors.redAccent;

  // ============================================
  // SHIMMER COLORS
  // ============================================

  /// Shimmer base color (loading state)
  static const Color shimmerBase = Color(0xFFE0E0E0);

  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // ============================================
  // NAVIGATION COLORS
  // ============================================

  /// Unselected nav icon
  static const Color navUnselected = Colors.black;

  /// Selected nav icon
  static const Color navSelected = Colors.white;

  /// Tab background when selected
  static const Color tabBackground = Colors.black;

  // ============================================
  // GRADIENT COLORS
  // ============================================

  /// Transparent white (for gradients)
  static const Color transparentWhite = Color.fromARGB(0, 255, 255, 255);

  /// Semi-transparent white
  static const Color semiTransparentWhite = Color.fromARGB(128, 255, 255, 255);

  /// More opaque white
  static const Color opaqueWhite = Color.fromARGB(204, 255, 255, 255);

  // ============================================
  // BORDER COLORS
  // ============================================

  /// Default border color
  static const Color border = Color(0xFF252525);

  /// Light border for cards
  static const Color borderLight = Color(0xFFE0E0E0);

  /// Divider color
  static const Color divider = Color(0xFFBDBDBD);
}
