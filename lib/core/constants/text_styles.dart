import 'package:campuszone/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  // Display
  static TextStyle get displayLarge => GoogleFonts.manrope(
      fontSize: 48.0,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.0,
      color: AppColors.textPrimary);
  static TextStyle get displayMedium => GoogleFonts.manrope(
      fontSize: 40.0,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.5,
      color: AppColors.textPrimary);
  static TextStyle get displaySmall => GoogleFonts.manrope(
      fontSize: 32.0,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary);

  // Headline
  static TextStyle get headlineLarge => GoogleFonts.manrope(
      fontSize: 28.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static TextStyle get headlineMedium => GoogleFonts.manrope(
      fontSize: 24.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static TextStyle get headlineSmall => GoogleFonts.manrope(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);

  // Title
  static TextStyle get titleLarge => GoogleFonts.manrope(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary);
  static TextStyle get titleMedium => GoogleFonts.manrope(
      fontSize: 16.0,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary);
  static TextStyle get titleSmall => GoogleFonts.manrope(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary);

  // Body
  static TextStyle get bodyLarge => GoogleFonts.inter(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary);
  static TextStyle get bodyMedium => GoogleFonts.inter(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: AppColors.textPrimary);
  static TextStyle get bodySmall => GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.textPrimary);

  // Label
  static TextStyle get labelLarge => GoogleFonts.inter(
      fontSize: 14.0,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary);
  static TextStyle get labelMedium => GoogleFonts.inter(
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary);
  static TextStyle get labelSmall => GoogleFonts.inter(
      fontSize: 11.0,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: AppColors.textPrimary);

  // Button
  static TextStyle get buttonLarge => GoogleFonts.manrope(
      fontSize: 18.0, fontWeight: FontWeight.w600, color: AppColors.white);
  static TextStyle get buttonMedium => GoogleFonts.manrope(
      fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.white);
  static TextStyle get buttonSmall => GoogleFonts.manrope(
      fontSize: 14.0, fontWeight: FontWeight.w600, color: AppColors.white);

  // Variants
  static TextStyle get caption =>
      bodySmall.copyWith(color: AppColors.textSecondary);
  static TextStyle get captionBold => bodySmall.copyWith(
      fontWeight: FontWeight.bold, color: AppColors.textSecondary);
  static TextStyle get bodyLargeBold =>
      bodyLarge.copyWith(fontWeight: FontWeight.bold);
  static TextStyle get bodyMediumBold =>
      bodyMedium.copyWith(fontWeight: FontWeight.bold);

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
