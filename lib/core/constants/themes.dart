import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'text_styles.dart';
import 'dimensions.dart';

/// Centralized theme configuration
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
/// )
/// ```
abstract class AppTheme {
  /// Light theme for the app
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,

        // Colors
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        canvasColor: AppColors.cardBackground,
        cardColor: AppColors.cardBackground,
        dividerColor: AppColors.divider,

        // Color scheme
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.primaryLight,
          surface: AppColors.cardBackground,
          error: AppColors.error,
          onPrimary: AppColors.textWhite,
          onSecondary: AppColors.textWhite,
          onSurface: AppColors.textPrimary,
          onError: AppColors.textWhite,
        ),

        // Typography
        textTheme: AppTextStyles.appTextTheme,

        // AppBar theme
        appBarTheme: AppBarTheme(
          elevation: AppElevation.none,
          backgroundColor: AppColors.scaffoldBackground,
          foregroundColor: AppColors.textPrimary,
          centerTitle: false,
          iconTheme: const IconThemeData(color: AppColors.primary),
          titleTextStyle: AppTextStyles.displaySmall.copyWith(
            color: AppColors.textPrimary,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.scaffoldBackground,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),

        // Card theme
        cardTheme: CardThemeData(
          elevation: AppElevation.card,
          color: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.cardRadius,
          ),
        ),

        // Button themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textWhite,
            elevation: AppElevation.none,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.xl,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
            textStyle: AppTextStyles.buttonMedium,
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: AppTextStyles.buttonMedium,
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.buttonRadius,
            ),
            textStyle: AppTextStyles.buttonMedium,
          ),
        ),

        // FAB theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          elevation: AppElevation.fab,
        ),

        // Input theme
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          border: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.inputRadius,
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
          labelStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
        ),

        // Dialog theme
        dialogTheme: DialogThemeData(
          elevation: AppElevation.dialog,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.dialogRadius,
          ),
          backgroundColor: AppColors.cardBackground,
        ),

        // SnackBar theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textWhite),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.snackbar),
          ),
        ),

        // Bottom navigation theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.scaffoldBackground,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
        ),

        // Divider theme
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 0,
        ),

        // Progress indicator theme
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.shimmerBase,
        ),

        // Checkbox theme
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(AppColors.textWhite),
        ),
      );

  /// System UI overlay style for status bar
  static const SystemUiOverlayStyle systemUiStyle = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.scaffoldBackground,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}
