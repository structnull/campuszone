import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized text styles using Google Fonts
///
/// Typography System:
/// - **Headings**: Manrope (modern, geometric sans-serif)
/// - **Body Text**: Inter (highly readable UI font)
///
/// Usage:
/// ```dart
/// Text('Welcome', style: AppTextStyles.displayMedium)
/// Text('Description', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary))
/// ```
abstract class AppTextStyles {
  // ============================================
  // DISPLAY STYLES (Manrope - for headings)
  // ============================================

  /// 48px - Hero headings, splash screens
  static TextStyle get displayLarge => GoogleFonts.manrope(
        fontSize: 48.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
      );

  /// 40px - Page titles, welcome messages
  static TextStyle get displayMedium => GoogleFonts.manrope(
        fontSize: 40.0,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
      );

  /// 32px - Section headers, card titles
  static TextStyle get displaySmall => GoogleFonts.manrope(
        fontSize: 32.0,
        fontWeight: FontWeight.w700,
      );

  // ============================================
  // HEADLINE STYLES (Manrope)
  // ============================================

  /// 28px - Large headlines
  static TextStyle get headlineLarge => GoogleFonts.manrope(
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
      );

  /// 24px - AppBar titles, modal headers
  static TextStyle get headlineMedium => GoogleFonts.manrope(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
      );

  /// 20px - Card headers, list titles
  static TextStyle get headlineSmall => GoogleFonts.manrope(
        fontSize: 20.0,
        fontWeight: FontWeight.w600,
      );

  // ============================================
  // TITLE STYLES (Manrope)
  // ============================================

  /// 18px - Subsection titles
  static TextStyle get titleLarge => GoogleFonts.manrope(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      );

  /// 16px - List item titles, navigation
  static TextStyle get titleMedium => GoogleFonts.manrope(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
      );

  /// 14px - Small titles, labels
  static TextStyle get titleSmall => GoogleFonts.manrope(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      );

  // ============================================
  // BODY STYLES (Inter - for readable text)
  // ============================================

  /// 16px - Primary body text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// 14px - Secondary body text, descriptions
  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  /// 12px - Captions, helper text
  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // ============================================
  // LABEL STYLES (Inter)
  // ============================================

  /// 14px - Form labels, chip text
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
      );

  /// 12px - Secondary labels
  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
      );

  /// 11px - Tiny labels, timestamps
  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  // ============================================
  // BUTTON STYLES (Manrope - bold, impactful)
  // ============================================

  /// 18px - Primary button text
  static TextStyle get buttonLarge => GoogleFonts.manrope(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      );

  /// 16px - Standard button text
  static TextStyle get buttonMedium => GoogleFonts.manrope(
        fontSize: 16.0,
        fontWeight: FontWeight.w600,
      );

  /// 14px - Small button text
  static TextStyle get buttonSmall => GoogleFonts.manrope(
        fontSize: 14.0,
        fontWeight: FontWeight.w600,
      );

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Get Manrope TextTheme for ThemeData
  static TextTheme get manropeTextTheme => GoogleFonts.manropeTextTheme();

  /// Get Inter TextTheme for ThemeData
  static TextTheme get interTextTheme => GoogleFonts.interTextTheme();

  /// Build a complete TextTheme with Manrope headings and Inter body
  static TextTheme get appTextTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
